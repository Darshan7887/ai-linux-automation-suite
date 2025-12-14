#!/bin/bash

# =========================================
# Script: security_audit.sh
# Purpose: Basic Linux security audit
# =========================================

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/ai_mock.sh"

REPORT_FILE="$BASE_DIR/reports/security_report.txt"

echo "SECURITY AUDIT REPORT" > "$REPORT_FILE"
echo "Generated at: $(date)" >> "$REPORT_FILE"
echo "==================================" >> "$REPORT_FILE"

log_info "Starting security audit"
# ---------------- OPEN PORTS AUDIT ----------------
log_info "Auditing open listening ports"

echo "" >> "$REPORT_FILE"
echo "Open Listening Ports:" >> "$REPORT_FILE"

if command -v ss >/dev/null 2>&1; then
    ss -tuln >> "$REPORT_FILE"
    log_info "Open ports captured using ss"
elif command -v netstat >/dev/null 2>&1; then
    netstat -tuln >> "$REPORT_FILE"
    log_info "Open ports captured using netstat"
else
    echo "No port inspection tool available" >> "$REPORT_FILE"
    log_warn "Unable to list open ports"
fi
# ---------------- SUDO USERS AUDIT ----------------
log_info "Auditing sudo users"

echo "" >> "$REPORT_FILE"
echo "Users with sudo access:" >> "$REPORT_FILE"

if getent group sudo >/dev/null 2>&1; then
    getent group sudo | cut -d: -f4 | tr ',' '\n' >> "$REPORT_FILE"
    log_info "Sudo users listed successfully"
else
    echo "Unable to determine sudo users" >> "$REPORT_FILE"
    log_warn "Sudo group not found"
fi
# ---------------- FAILED SSH LOGIN AUDIT ----------------
log_info "Auditing failed SSH login attempts"

AUTH_LOG="/var/log/auth.log"

echo "" >> "$REPORT_FILE"
echo "Failed SSH Login Attempts:" >> "$REPORT_FILE"

if [ -f "$AUTH_LOG" ]; then
    FAILED_SSH_COUNT=$(grep -i "failed password" "$AUTH_LOG" | wc -l)
    echo "Total failed SSH login attempts: $FAILED_SSH_COUNT" >> "$REPORT_FILE"
    log_info "Failed SSH login attempts counted: $FAILED_SSH_COUNT"
else
    echo "Auth log not found" >> "$REPORT_FILE"
    log_warn "Auth log file not found"
fi
log_info "Generating AI security assessment"

OPEN_PORTS_COUNT=$(ss -tuln | tail -n +2 | wc -l)
SUDO_USERS_COUNT=$(getent group sudo | cut -d: -f4 | tr ',' '\n' | wc -l)

RISK_SCORE=0

if [ "$OPEN_PORTS_COUNT" -gt 20 ]; then
  RISK_SCORE=$((RISK_SCORE + 40))
fi

if [ "$SUDO_USERS_COUNT" -gt 2 ]; then
  RISK_SCORE=$((RISK_SCORE + 30))
fi

if [ "$FAILED_SSH" -gt 5 ]; then
  RISK_SCORE=$((RISK_SCORE + 30))
fi

{
  echo ""
  echo "AI SECURITY RISK ASSESSMENT"
  echo "--------------------------"
  echo "Risk Score: $RISK_SCORE / 100"

  if [ "$RISK_SCORE" -lt 30 ]; then
    echo "Status: LOW RISK"
    echo "Recommendation: Security posture is healthy."
  elif [ "$RISK_SCORE" -lt 70 ]; then
    echo "Status: MEDIUM RISK"
    echo "Recommendation: Review open ports and sudo users."
  else
    echo "Status: HIGH RISK"
    echo "Recommendation: Immediate security hardening required."
  fi
} >> "$REPORT_FILE"
