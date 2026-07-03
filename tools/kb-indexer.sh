#!/bin/bash
# kb-indexer.sh - KB Domain Indexer
# Version: 1.0

set -e

# Default KB root - try kb/ first, then current dir
KB_ROOT="kb"
if [ ! -d "$KB_ROOT" ]; then
  KB_ROOT="."
fi
[ -n "$KB_DIR" ] && KB_ROOT="$KB_DIR"

# Ensure kb directory exists
verify_kb_dir() {
  local kb_dir="$1"
  if [ ! -d "$kb_dir" ]; then
    echo "Error: KB directory not found: $kb_dir" >&2
    exit 1
  fi
}

# Detect current timestamp
CURRENT_TIMESTAMP=$(date +%s)
CURRENT_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get age in days from mtime
get_age_days() {
  local mtime=$1
  local current=$2
  local seconds_old=$((current - mtime))
  echo $((seconds_old / 86400))
}

# Determine freshness status
get_freshness_status() {
  local age_days=$1
  if [ "$age_days" -lt 8 ]; then
    echo "fresh"
  elif [ "$age_days" -lt 31 ]; then
    echo "recent"
  else
    echo "stale"
  fi
}

# Calculate confidence score
get_confidence() {
  local age_days=$1
  local ratio=$((age_days * 100 / 90))
  [ $ratio -gt 100 ] && ratio=100
  local sqrt_ratio=$((ratio / 2 + 50 / (ratio + 1)))
  local confidence=$((100 - sqrt_ratio))
  [ $confidence -lt 0 ] && confidence=0
  echo $confidence
}

# ===================================================================
# COMMAND: index
# ===================================================================

cmd_index() {
  local kb_dir="${1:-kb}"
  verify_kb_dir "$kb_dir"
  KB_ROOT="$kb_dir"

  local index_file="$kb_dir/kb-index.yaml"

  {
    echo "generated_at: \"$CURRENT_ISO\""
    echo "kb_root: \"$kb_dir/\""
    echo "scan_version: 1"
    echo "domains:"

    for domain_dir in "$kb_dir"/*/ ; do
      [ -d "$domain_dir" ] || continue

      domain_name=$(basename "$domain_dir")
      [[ "$domain_name" == "_"* ]] && continue
      [[ "$domain_name" == "."* ]] && continue

      local latest_mtime=0

      if [ -f "$domain_dir/index.md" ]; then
        latest_mtime=$(stat -c%Y "$domain_dir/index.md" 2>/dev/null || stat -f%m "$domain_dir/index.md" 2>/dev/null || echo 0)
      fi

      while IFS= read -r -d '' file; do
        local file_mtime=$(stat -c%Y "$file" 2>/dev/null || stat -f%m "$file" 2>/dev/null || echo 0)
        if [ "$file_mtime" -gt "$latest_mtime" ]; then
          latest_mtime=$file_mtime
        fi
      done < <(find "$domain_dir" -maxdepth 3 -type f -name "*.md" -print0 2>/dev/null)

      if [ "$latest_mtime" -eq 0 ]; then
        latest_mtime=$(stat -c%Y "$domain_dir" 2>/dev/null || stat -f%m "$domain_dir" 2>/dev/null || echo 0)
      fi

      local last_updated=$(date -u -d "@$latest_mtime" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
                          date -u -r "$latest_mtime" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
                          echo "$CURRENT_ISO")

      local age_days=$(get_age_days "$latest_mtime" "$CURRENT_TIMESTAMP")
      local status=$(get_freshness_status "$age_days")
      local confidence=$(get_confidence "$age_days")

      local file_count=$(find "$domain_dir" -type f -name "*.md" 2>/dev/null | wc -l)
      local has_index="false"
      [ -f "$domain_dir/index.md" ] && has_index="true"

      echo "  $domain_name:"
      echo "    path: \"$kb_dir/$domain_name/\""
      echo "    last_updated: \"$last_updated\""
      echo "    age_days: $age_days"
      echo "    status: $status"
      echo "    confidence: $((confidence))"
      echo "    file_count: $file_count"
      echo "    has_index: $has_index"
      echo "    mtime: $latest_mtime"
    done
  } | tee "$index_file"

  echo "" >&2
  echo "Index written to: $index_file" >&2
}

# ===================================================================
# COMMAND: list
# ===================================================================

cmd_list() {
  local format="table"

  while [ $# -gt 0 ]; do
    case "$1" in
      --format)
        format="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  verify_kb_dir "$KB_ROOT"

  if [ ! -f "$KB_ROOT/kb-index.yaml" ]; then
    cmd_index "$KB_ROOT" > /dev/null 2>&1
  fi

  case "$format" in
    table)
      {
        echo "domain_id"
        grep "^  [a-z]" "$KB_ROOT/kb-index.yaml" | sed 's/^  //;s/:$//'
      }
      ;;
    json)
      echo "["
      local first=1
      grep "^  [a-z]" "$KB_ROOT/kb-index.yaml" | sed 's/^  //;s/:$//' | while read -r domain; do
        domain_info=$(grep -A 8 "^  $domain:" "$KB_ROOT/kb-index.yaml")
        last_updated=$(echo "$domain_info" | grep "last_updated:" | awk -F': ' '{print $2}')
        age_days=$(echo "$domain_info" | grep "age_days:" | awk -F': ' '{print $2}')
        status=$(echo "$domain_info" | grep "status:" | awk -F': ' '{print $2}')
        confidence=$(echo "$domain_info" | grep "confidence:" | awk -F': ' '{print $2}')

        [ "$first" -eq 1 ] && first=0 || echo ","
        cat <<JSONEOF
  {
    "domain_id": "$domain",
    "status": "$status",
    "age_days": $age_days,
    "confidence": $confidence,
    "last_updated": "$last_updated"
  }
JSONEOF
      done
      echo "]"
      ;;
    *)
      echo "Unknown format: $format" >&2
      exit 1
      ;;
  esac
}

# ===================================================================
# COMMAND: freshness
# ===================================================================

cmd_freshness() {
  local domain_id=""
  local format="text"

  while [ $# -gt 0 ]; do
    case "$1" in
      --domain)
        domain_id="$2"
        shift 2
        ;;
      --format)
        format="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -z "$domain_id" ]; then
    echo "Error: --domain is required" >&2
    exit 1
  fi

  verify_kb_dir "$KB_ROOT"

  if [ ! -f "$KB_ROOT/kb-index.yaml" ]; then
    cmd_index "$KB_ROOT" > /dev/null 2>&1
  fi

  local domain_info=$(grep -A 8 "^  $domain_id:" "$KB_ROOT/kb-index.yaml" 2>/dev/null)

  if [ -z "$domain_info" ]; then
    echo "Error: Domain not found: $domain_id" >&2
    exit 1
  fi

  local last_updated=$(echo "$domain_info" | grep "last_updated:" | awk -F': ' '{print $2}')
  local age_days=$(echo "$domain_info" | grep "age_days:" | awk -F': ' '{print $2}')
  local status=$(echo "$domain_info" | grep "status:" | awk -F': ' '{print $2}')
  local confidence=$(echo "$domain_info" | grep "confidence:" | awk -F': ' '{print $2}')

  case "$format" in
    text)
      echo "Domain: $domain_id"
      echo "Status: $status"
      echo "Age: $age_days days"
      echo "Confidence: $confidence%"
      echo "Last updated: $last_updated"
      ;;
    json)
      echo "{"
      echo "  \"domain_id\": \"$domain_id\","
      echo "  \"status\": \"$status\","
      echo "  \"age_days\": $age_days,"
      echo "  \"confidence\": $confidence,"
      echo "  \"last_updated\": \"$last_updated\""
      echo "}"
      ;;
    *)
      echo "Unknown format: $format" >&2
      exit 1
      ;;
  esac
}

# ===================================================================
# MAIN
# ===================================================================

if [ $# -eq 0 ]; then
  echo "Usage: $(basename "$0") <command> [options]" >&2
  echo "" >&2
  echo "Commands:" >&2
  echo "  index [kb_dir]                    Build KB index" >&2
  echo "  list [--format json|table]        List all domains" >&2
  echo "  freshness --domain <id> [--format json|text]   Check domain freshness" >&2
  exit 1
fi

cmd="$1"
shift

case "$cmd" in
  index)
    cmd_index "$@"
    ;;
  list)
    cmd_list "$@"
    ;;
  freshness)
    cmd_freshness "$@"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
