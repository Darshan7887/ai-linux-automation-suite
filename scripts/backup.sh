#!/bin/bash

# =========================================
# Script: backup.sh
# Purpose: Automated backup & compression
# =========================================

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$BASE_DIR/config/backup.conf"
source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/ai_mock.sh"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DEST/backup_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DEST"

log_info "Starting automated backup"

# Create backup archive
tar -czf "$BACKUP_PATH" $BACKUP_DIRS

log_info "Backup created at $BACKUP_PATH"

# Cleanup old backups
find "$BACKUP_DEST" -type f -mtime +"$RETENTION_DAYS" -delete
log_info "Old backups cleaned (>${RETENTION_DAYS} days)"

# AI Summary
generate_ai_summary "Backup completed successfully at $TIMESTAMP" \
"$BASE_DIR/reports/ai_backup_summary.txt"

log_info "AI backup summary generated"
