#!/bin/bash

# ============================================
# Script: system_health.sh
# Purpose: System health monitoring
# ============================================

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/ai_mock.sh"

REPORT_FILE="$BASE_DIR/reports/health_report.txt"
AI_REPORT="$BASE_DIR/reports/ai_summary.txt"
log_info "Collecting CPU usage"

# ---------------- CPU USAGE ----------------
require_command top
require_command awk

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

echo "===============================" > "$REPORT_FILE"
echo " SYSTEM HEALTH REPORT" >> "$REPORT_FILE"
echo " Generated at: $(date)" >> "$REPORT_FILE"
echo "===============================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "CPU Usage: ${CPU_USAGE}%" >> "$REPORT_FILE"

log_info "CPU usage collected: ${CPU_USAGE}%"
log_info "Generating AI system summary"
generate_ai_summary "$REPORT_FILE" "$AI_REPORT"
log_info "AI summary generated"
