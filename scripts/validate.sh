#!/usr/bin/env bash
#
# validate.sh — Run from the Azure VM (via Tailscale SSH) to verify
# end-to-end subnet routing connectivity.
#
# Usage:
#   tailscale ssh azureuser@tailscale-lab-vm 'bash -s' < scripts/validate.sh
#   or copy to the VM and run directly

set -euo pipefail

# ── Configure these for your environment ──
SUBNET_ROUTER_HOSTNAME="${SUBNET_ROUTER_HOSTNAME:-home-subnet-router}"
GATEWAY_IP="${GATEWAY_IP:-192.168.1.254}"
PLEX_IP="${PLEX_IP:-192.168.1.169}"
PLEX_PORT="${PLEX_PORT:-32400}"
TAILNET_NAME="${TAILNET_NAME:-tail7d707f.ts.net}"

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
  if output=$("$@" 2>&1); then
    echo -e " [${GREEN}PASS${NC}]"
    ((PASS++))
  else
    echo -e " [${RED}FAIL${NC}]"
    echo -e "  ${YELLOW}→ $output${NC}"
    ((FAIL++))
  fi
}

echo "============================================"
echo " Tailscale Subnet Router Lab — Validation"
echo "============================================"
echo ""

# 1. Tailscale daemon running and authenticated
check "Tailscale status" tailscale status

# 2. Ping the subnet router via Tailscale
check "Ping subnet router ($SUBNET_ROUTER_HOSTNAME)" tailscale ping -c 1 "$SUBNET_ROUTER_HOSTNAME"

# 3. Ping the home LAN gateway via subnet route
check "Ping home gateway ($GATEWAY_IP)" ping -c 1 -W 3 "$GATEWAY_IP"

# 4. Ping Plex server via subnet route
check "Ping Plex host ($PLEX_IP)" ping -c 1 -W 3 "$PLEX_IP"

# 5. Curl Plex Web UI
check "Curl Plex ($PLEX_IP:$PLEX_PORT/web)" \
  curl -sf --max-time 5 -o /dev/null -w "%{http_code}" "http://$PLEX_IP:$PLEX_PORT/web"

# 6. Verify this machine is on the tailnet
check "Tailnet membership ($TAILNET_NAME)" \
  bash -c "tailscale whois --json \$(tailscale ip -4) | grep -q $TAILNET_NAME"

echo ""
echo "============================================"
echo -e " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "============================================"

exit "$FAIL"
