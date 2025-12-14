#!/bin/bash

# ============================================
# Script: log_monitor.sh
# Purpose: System log monitoring & incident detection
# ============================================

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/ai_mock.sh"

LOG_REPORT="$BASE_DIR/reports/log_report.txt"
AI_LOG_SUMMARY="$BASE_DIR/reports/ai_log_summary.txt"
log_info "Starting system log monitoring"

# ---------------- SYSLOG CHECK ----------------
SYSLOG_FILE="/var/log/syslog"

if [ ! -f "$SYSLOG_FILE" ]; then
    log_error "Syslog file not found: $SYSLOG_FILE"
    exit 1
fi

log_info "Scanning syslog for errors and warnings"

echo "===============================" > "$LOG_REPORT"
echo " SYSTEM LOG REPORT" >> "$LOG_REPORT"
echo " Generated at: $(date)" >> "$LOG_REPORT"
echo "===============================" >> "$LOG_REPORT"
echo "" >> "$LOG_REPORT"

ERROR_COUNT=$(grep -i "error" "$SYSLOG_FILE" | wc -l)
WARNING_COUNT=$(grep -i "warning" "$SYSLOG_FILE" | wc -l)

echo "Total Errors Found   : $ERROR_COUNT" >> "$LOG_REPORT"
echo "Total Warnings Found : $WARNING_COUNT" >> "$LOG_REPORT"

log_info "Syslog scan completed: Errors=$ERROR_COUNT, Warnings=$WARNING_COUNT"
# ---------------- SSH FAILED LOGIN CHECK ----------------
AUTH_LOG="/var/log/auth.log"

if [ ! -f "$AUTH_LOG" ]; then
    log_warn "Auth log not found: $AUTH_LOG"
else
    log_info "Scanning auth log for failed SSH login attempts"

    FAILED_SSH_COUNT=$(grep -i "failed password" "$AUTH_LOG" | wc -l)

    echo "" >> "$LOG_REPORT"
    echo "Failed SSH Login Attempts: $FAILED_SSH_COUNT" >> "$LOG_REPORT"

    log_info "Failed SSH login attempts detected: $FAILED_SSH_COUNT"
fi
# ---------------- AI INCIDENT SUMMARY ----------------
log_info "Generating AI incident summary"

generate_ai_summary "$LOG_REPORT" "$AI_LOG_SUMMARY"

log_info "AI incident summary generated"
