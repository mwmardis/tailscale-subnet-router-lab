#!/usr/bin/env bash
#
# validate.sh — Run from the Azure VM (via Tailscale SSH) to verify
# end-to-end subnet routing connectivity.
#
# Usage:
#   cat scripts/validate.sh | sed 's/\r$//' | tailscale ssh <admin_username>@tailscalevm 'bash -s'
#   or copy to the VM and run directly

set -uo pipefail

# ── Configure these for your environment ──
SUBNET_ROUTER_HOSTNAME="${SUBNET_ROUTER_HOSTNAME:-home-subnet-router}"
PLEX_IP="${PLEX_IP:-192.168.1.169}"
PLEX_PORT="${PLEX_PORT:-32400}"
PRINTER_IP="${PRINTER_IP:-192.168.1.223}"
XBOX_IP="${XBOX_IP:-192.168.1.222}"
TAILNET_NAME="${TAILNET_NAME:-bee-massometer.ts.net}"
MAX_RETRIES=3
RETRY_DELAY=2

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
  local description="$1"
  shift
  printf "%-50s" "$description"
  for i in $(seq 1 "$MAX_RETRIES"); do
    if output=$("$@" 2>&1); then
      echo -e " [${GREEN}PASS${NC}]"
      ((PASS++))
      return
    fi
    [ "$i" -lt "$MAX_RETRIES" ] && sleep "$RETRY_DELAY"
  done
  echo -e " [${RED}FAIL${NC}]"
  echo -e "  ${YELLOW}→ $output${NC}"
  ((FAIL++))
}

echo "============================================"
echo " Tailscale Subnet Router Lab — Validation"
echo "============================================"
echo ""

# 1. Tailscale daemon running and authenticated
check "Tailscale status" tailscale status

# 2. Ping the subnet router via Tailscale
check "Ping subnet router ($SUBNET_ROUTER_HOSTNAME)" \
  bash -c "tailscale ping -c 1 '$SUBNET_ROUTER_HOSTNAME' 2>&1 | grep -q 'pong'"

# 3. Ping printer via subnet route
check "Ping printer ($PRINTER_IP)" sudo ping -c 1 -W 5 "$PRINTER_IP"

# 4. Ping Xbox via subnet route
check "Ping Xbox ($XBOX_IP)" sudo ping -c 1 -W 5 "$XBOX_IP"

# 5. Curl Plex Web UI via subnet route
check "Curl Plex ($PLEX_IP:$PLEX_PORT/web)" \
  sudo curl -sL --max-time 10 -o /dev/null -w "%{http_code}" "http://$PLEX_IP:$PLEX_PORT/web"

# 6. Show subnet route path — prove traffic flows through subnet router
echo ""
echo "── Subnet route path ──"
echo "  Route to $PLEX_IP:"
echo "    $(ip route get "$PLEX_IP" 2>/dev/null)"
echo "  Subnet router providing route:"
echo "    $(tailscale status | grep subnet-router || tailscale status | grep home)"
echo ""

# 7. Verify this machine is on the tailnet
check "Tailnet membership ($TAILNET_NAME)" \
  bash -c "tailscale whois --json \$(tailscale ip -4) | grep -q $TAILNET_NAME"

echo ""
echo "============================================"
echo -e " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "============================================"

exit "$FAIL"
