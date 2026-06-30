#!/bin/bash
#
# security-scan.sh — Pre-write security gate for Harness V3
# Detects secrets, PII, and suspicious patterns before file writes
#
# Usage:
#   security-scan.sh scan <files...>     # Detect secrets
#   security-scan.sh pii <files...>      # Detect PII
#   security-scan.sh check-file <file>   # Pre-write check
#   security-scan.sh report               # Generate summary
#   security-scan.sh audit                # Full audit
#
# Exit Codes:
#   0 = Safe (no findings or LOW only)
#   1 = MEDIUM warnings (non-blocking)
#   2 = HIGH/CRITICAL findings (blocking)

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly AUDIT_LOG="${AUDIT_LOG:-.specs/changes/w9-security/evidence/security-audit.log}"
readonly CACHE_DIR=".security-scan-cache"

# Ensure cache dir exists
mkdir -p "${CACHE_DIR}"

# Severity codes
readonly SEVERITY_LOW=0
readonly SEVERITY_MEDIUM=1
readonly SEVERITY_HIGH=2
readonly SEVERITY_CRITICAL=2

# Global state
FINDINGS_HIGH=0
FINDINGS_MEDIUM=0
FINDINGS_LOW=0

#######################################
# Pattern Definitions (from security-contract.md)
#######################################

declare -A SECRET_PATTERNS=(
  [AWS_ACCESS_KEY]="AKIA[0-9A-Z]{16}"
  [AWS_SECRET_KEY]="aws_secret_access_key\s*=\s*[^\s]{20,}"
  [GITHUB_TOKEN]="ghp_[A-Za-z0-9_]{36,255}"
  [SLACK_TOKEN]="xoxb-[0-9]{10,13}-[0-9]{10,13}-[A-Za-z0-9]{24}"
  [GENERIC_API_KEY]="api[_-]?key\s*[:=]\s*[^\s]{16,}"
  [JWT_TOKEN]="Bearer\s+eyJ[A-Za-z0-9_-]{10,}"
  [PRIVATE_KEY]="-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----"
  [PASSWORD_VAR]="password\s*[:=]\s*['\"][^\s]{8,}['\"]"
)

declare -A SECRET_SEVERITY=(
  [AWS_ACCESS_KEY]="HIGH"
  [AWS_SECRET_KEY]="HIGH"
  [GITHUB_TOKEN]="HIGH"
  [SLACK_TOKEN]="HIGH"
  [GENERIC_API_KEY]="MEDIUM"
  [JWT_TOKEN]="MEDIUM"
  [PRIVATE_KEY]="HIGH"
  [PASSWORD_VAR]="MEDIUM"
)

declare -A PII_PATTERNS=(
  [SSN]='\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b'
  [PHONE_US]='(\d{3}[-.\s]?){2}\d{4}'
  [CREDIT_CARD]='\b[0-9]{4}[\s-]?[0-9]{4}[\s-]?[0-9]{4}[\s-]?[0-9]{4}\b'
  [EMAIL]='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
)

declare -A PII_SEVERITY=(
  [SSN]="HIGH"
  [PHONE_US]="MEDIUM"
  [CREDIT_CARD]="HIGH"
  [EMAIL]="LOW"
)

#######################################
# Logging Functions
#######################################

log_audit() {
  local level="$1" severity="$2" pattern="$3" file="$4" line="$5"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  echo "[$timestamp] [$level] $severity: $pattern detected at $file:$line (redacted)" >> "${AUDIT_LOG}"
}

log_console() {
  local level="$1" severity="$2" pattern="$3" file="$4" line="$5"
  
  case "$severity" in
    HIGH|CRITICAL)
      echo "[BLOCKED] $severity: $pattern detected at $file:$line (redacted)" >&2
      ;;
    MEDIUM)
      echo "[WARNED] $severity: $pattern detected at $file:$line (redacted)" >&2
      ;;
    LOW)
      # Low severity: console suppressed, audit only
      ;;
  esac
}

#######################################
# Scanning Functions
#######################################

scan_file_for_secrets() {
  local file="$1"
  local exit_code=0
  
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2
    return 2
  fi
  
  # Skip binary and vendor files
  if [[ "$file" =~ \.(png|jpg|zip|gz|tar|bin)$ ]]; then
    return 0
  fi
  if [[ "$file" =~ (node_modules|venv|\.git)/ ]]; then
    return 0
  fi
  
  local line_num=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    ((line_num++))
    
    for pattern_name in "${!SECRET_PATTERNS[@]}"; do
      local pattern="${SECRET_PATTERNS[$pattern_name]}"
      local severity="${SECRET_SEVERITY[$pattern_name]}"
      
      if grep -qE "$pattern" <(echo "$line") 2>/dev/null; then
        log_audit "INFO" "$severity" "$pattern_name" "$file" "$line_num"
        log_console "INFO" "$severity" "$pattern_name" "$file" "$line_num"
        
        case "$severity" in
          HIGH|CRITICAL)
            FINDINGS_HIGH=$((FINDINGS_HIGH + 1))
            exit_code=2
            ;;
          MEDIUM)
            FINDINGS_MEDIUM=$((FINDINGS_MEDIUM + 1))
            if [[ $exit_code -ne 2 ]]; then
              exit_code=1
            fi
            ;;
          LOW)
            FINDINGS_LOW=$((FINDINGS_LOW + 1))
            ;;
        esac
      fi
    done
  done < "$file"
  
  return $exit_code
}

scan_file_for_pii() {
  local file="$1"
  local exit_code=0
  
  if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file" >&2
    return 2
  fi
  
  # Skip binary and vendor files
  if [[ "$file" =~ \.(png|jpg|zip|gz|tar|bin)$ ]]; then
    return 0
  fi
  if [[ "$file" =~ (node_modules|venv|\.git)/ ]]; then
    return 0
  fi
  
  local line_num=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    ((line_num++))
    
    for pattern_name in "${!PII_PATTERNS[@]}"; do
      local pattern="${PII_PATTERNS[$pattern_name]}"
      local severity="${PII_SEVERITY[$pattern_name]}"
      
      if grep -qE "$pattern" <(echo "$line") 2>/dev/null; then
        log_audit "INFO" "$severity" "$pattern_name" "$file" "$line_num"
        log_console "INFO" "$severity" "$pattern_name" "$file" "$line_num"
        
        case "$severity" in
          HIGH|CRITICAL)
            FINDINGS_HIGH=$((FINDINGS_HIGH + 1))
            exit_code=2
            ;;
          MEDIUM)
            FINDINGS_MEDIUM=$((FINDINGS_MEDIUM + 1))
            if [[ $exit_code -ne 2 ]]; then
              exit_code=1
            fi
            ;;
          LOW)
            FINDINGS_LOW=$((FINDINGS_LOW + 1))
            ;;
        esac
      fi
    done
  done < "$file"
  
  return $exit_code
}

#######################################
# Command Handlers
#######################################

cmd_scan() {
  local exit_code=0
  
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 scan <files...>" >&2
    return 1
  fi
  
  for file in "$@"; do
    if ! scan_file_for_secrets "$file"; then
      exit_code=$?
    fi
  done
  
  return $exit_code
}

cmd_pii() {
  local exit_code=0
  
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 pii <files...>" >&2
    return 1
  fi
  
  for file in "$@"; do
    if ! scan_file_for_pii "$file"; then
      exit_code=$?
    fi
  done
  
  return $exit_code
}

cmd_check_file() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Usage: $0 check-file <file>" >&2
    return 1
  fi
  
  local exit_code=0
  
  if ! scan_file_for_secrets "$file"; then
    exit_code=$?
  fi
  
  if ! scan_file_for_pii "$file"; then
    local pii_exit=$?
    if [[ $exit_code -ne 2 && $pii_exit -eq 2 ]]; then
      exit_code=$pii_exit
    fi
  fi
  
  return $exit_code
}

cmd_report() {
  echo ""
  echo "Security Scan Report"
  echo "===================="
  echo ""
  echo "HIGH/CRITICAL findings:  $FINDINGS_HIGH"
  echo "MEDIUM warnings:         $FINDINGS_MEDIUM"
  echo "LOW info:                $FINDINGS_LOW"
  echo ""
  
  if [[ -f "$AUDIT_LOG" ]]; then
    echo "Last 10 audit entries:"
    echo ""
    tail -n 10 "$AUDIT_LOG" || echo "(No audit entries)"
  else
    echo "Audit log: $AUDIT_LOG (not created yet)"
  fi
  echo ""
  
  if [[ $FINDINGS_HIGH -gt 0 ]]; then
    echo "Status: BLOCKED (HIGH findings detected)"
    return 2
  elif [[ $FINDINGS_MEDIUM -gt 0 ]]; then
    echo "Status: WARNED (MEDIUM findings detected)"
    return 1
  else
    echo "Status: SAFE"
    return 0
  fi
}

cmd_audit() {
  if [[ -f "$AUDIT_LOG" ]]; then
    echo "Full audit trail: $AUDIT_LOG"
    echo ""
    cat "$AUDIT_LOG"
  else
    echo "No audit entries yet"
  fi
}

#######################################
# Main
#######################################

main() {
  local command="${1:-}"
  
  case "$command" in
    scan)
      shift || true
      cmd_scan "$@"
      ;;
    pii)
      shift || true
      cmd_pii "$@"
      ;;
    check-file)
      shift || true
      cmd_check_file "$@"
      ;;
    report)
      cmd_report
      ;;
    audit)
      cmd_audit
      ;;
    *)
      echo "Security Scan Tool"
      echo ""
      echo "Usage:"
      echo "  $0 scan <files...>      # Detect secrets"
      echo "  $0 pii <files...>       # Detect PII"
      echo "  $0 check-file <file>    # Pre-write check"
      echo "  $0 report               # Generate summary"
      echo "  $0 audit                # Full audit log"
      echo ""
      return 1
      ;;
  esac
}

main "$@"
