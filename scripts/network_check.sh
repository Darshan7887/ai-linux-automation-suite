#!/bin/bash

# =========================================
# Script: network_check.sh
# Purpose: Network connectivity & health check
# =========================================

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/ai_mock.sh"

REPORT_FILE="$BASE_DIR/reports/network_report.txt"

echo "NETWORK STATUS REPORT" > "$REPORT_FILE"
echo "Generated at: $(date)" >> "$REPORT_FILE"
echo "==================================" >> "$REPORT_FILE"

log_info "Starting network status check"
# ---------------- INTERNET CONNECTIVITY ----------------
log_info "Checking internet connectivity"

PING_TARGET="8.8.8.8"

if ping -c 1 "$PING_TARGET" >/dev/null 2>&1; then
    echo "Internet Connectivity: AVAILABLE" >> "$REPORT_FILE"
    log_info "Internet connectivity is available"
else
    echo "Internet Connectivity: NOT AVAILABLE" >> "$REPORT_FILE"
    log_warn "Internet connectivity is not available"
fi
# ---------------- DNS RESOLUTION ----------------
log_info "Checking DNS resolution"

DNS_TEST_DOMAIN="google.com"

if getent hosts "$DNS_TEST_DOMAIN" >/dev/null 2>&1; then
    echo "DNS Resolution: WORKING ($DNS_TEST_DOMAIN)" >> "$REPORT_FILE"
    log_info "DNS resolution working for $DNS_TEST_DOMAIN"
else
    echo "DNS Resolution: FAILED ($DNS_TEST_DOMAIN)" >> "$REPORT_FILE"
    log_warn "DNS resolution failed for $DNS_TEST_DOMAIN"
fi
# ---------------- NETWORK LATENCY ----------------
log_info "Measuring network latency"

LATENCY_TARGET="8.8.8.8"

PING_RESULT=$(ping -c 4 "$LATENCY_TARGET" | tail -1 | awk -F '/' '{print $5}')

if [ -n "$PING_RESULT" ]; then
    echo "Average Latency to $LATENCY_TARGET: ${PING_RESULT} ms" >> "$REPORT_FILE"
    log_info "Average latency measured: ${PING_RESULT} ms"
else
    echo "Average Latency: Unable to measure" >> "$REPORT_FILE"
    log_warn "Latency measurement failed"
fi
# ---------------- OPEN PORTS CHECK ----------------
log_info "Checking open listening ports"

echo "" >> "$REPORT_FILE"
echo "Open Listening Ports:" >> "$REPORT_FILE"

if command -v ss >/dev/null 2>&1; then
    ss -tuln >> "$REPORT_FILE"
    log_info "Open ports listed using ss"
elif command -v netstat >/dev/null 2>&1; then
    netstat -tuln >> "$REPORT_FILE"
    log_info "Open ports listed using netstat"
else
    echo "Unable to detect open ports (ss/netstat not found)" >> "$REPORT_FILE"
    log_warn "No port scanning tool available"
fi
# ---------------- AI NETWORK SUMMARY ----------------
log_info "Generating AI network health summary"

generate_ai_summary "$REPORT_FILE" "$BASE_DIR/reports/ai_network_summary.txt"

log_info "AI network health summary generated"
