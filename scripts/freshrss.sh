#!/bin/bash
# FreshRSS CLI - Query headlines from a FreshRSS instance
# Uses Google Reader compatible API
#
# Requires environment variables:
#   FRESHRSS_URL - Your FreshRSS instance URL (e.g., https://freshrss.example.com)
#   FRESHRSS_USER - Your FreshRSS username
#   FRESHRSS_API_PASSWORD - Your FreshRSS API password (set in FreshRSS → Settings → Profile → API)
#
# Usage:
#   freshrss.sh headlines [--count N] [--hours N] [--category NAME] [--unread]
#   freshrss.sh categories
#   freshrss.sh feeds

set -e

# --- Config ---
if [ -z "$FRESHRSS_URL" ] || [ -z "$FRESHRSS_USER" ] || [ -z "$FRESHRSS_API_PASSWORD" ]; then
  echo "Error: Required environment variables not set." >&2
  echo "Set FRESHRSS_URL, FRESHRSS_USER, and FRESHRSS_API_PASSWORD" >&2
  exit 1
fi

API_BASE="${FRESHRSS_URL}/api/greader.php"

# --- Auth ---
auth_login() {
  local RESPONSE
  RESPONSE=$(curl -s "${API_BASE}/accounts/ClientLogin?Email=${FRESHRSS_USER}&Passwd=${FRESHRSS_API_PASSWORD}")
  AUTH_TOKEN=$(echo "$RESPONSE" | grep "Auth=" | cut -d'=' -f2)
  if [ -z "$AUTH_TOKEN" ]; then
    echo "Error: Authentication failed" >&2
    echo "$RESPONSE" >&2
    exit 1
  fi
}

api_get() {
  local ENDPOINT="$1"
  curl -s -H "Authorization:GoogleLogin auth=${AUTH_TOKEN}" "${API_BASE}/reader/api/0/${ENDPOINT}"
}

api_post() {
  local ENDPOINT="$1"
  shift
  curl -s -H "Authorization:GoogleLogin auth=${AUTH_TOKEN}" -X POST "${API_BASE}/reader/api/0/${ENDPOINT}" "$@"
}

# --- Commands ---

cmd_categories() {
  auth_login
  api_get "tag/list?output=json" | jq -r '.tags[] | select(.id | contains("/label/")) | .id | split("/label/")[1]'
}

cmd_feeds() {
  auth_login
  api_get "subscription/list?output=json" | jq -r '.subscriptions[] | "\(.title) [\(.categories[0].label // "uncategorized")]"'
}

cmd_headlines() {
  local COUNT=20
  local HOURS=""
  local CATEGORY=""
  local SEARCH=""
  local FEED=""
  local STARRED=false
  local UNREAD_ONLY=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --count) COUNT="$2"; shift 2 ;;
      --hours) HOURS="$2"; shift 2 ;;
      --category) CATEGORY="$2"; shift 2 ;;
      --search) SEARCH="$2"; shift 2 ;;
      --feed) FEED="$2"; shift 2 ;;
      --starred) STARRED=true; shift ;;
      --unread) UNREAD_ONLY=true; shift ;;
      *) shift ;;
    esac
  done

  auth_login

  # Build stream URL
  local URL="stream/contents"
  if [ -n "$FEED" ]; then
    URL="${URL}/feed/${FEED}"
  elif [ "$STARRED" = true ]; then
    URL="${URL}/user/-/state/com.google/starred"
  elif [ -n "$CATEGORY" ]; then
    URL="${URL}/user/-/label/${CATEGORY}"
  else
    URL="${URL}/user/-/state/com.google/reading-list"
  fi

  URL="${URL}?output=json&n=${COUNT}"

  # Add time filter
  if [ -n "$HOURS" ]; then
    local SINCE
    SINCE=$(date -v-${HOURS}H +%s 2>/dev/null || date -d "${HOURS} hours ago" +%s 2>/dev/null)
    if [ -n "$SINCE" ]; then
      URL="${URL}&ot=${SINCE}"
    fi
  fi

  # Add unread filter
  if [ "$UNREAD_ONLY" = true ]; then
    URL="${URL}&xt=user/-/state/com.google/read"
  fi

  local RESPONSE
  RESPONSE=$(api_get "$URL")

  # Format output
  local JQ_ARGS=("-r")
  local JQ_PROG='.items[] | '

  if [ -n "$SEARCH" ]; then
    JQ_ARGS+=(--arg search "$SEARCH")
    JQ_PROG+='select([.title, (.summary | if type=="object" then .content else null end), (.content | if type=="object" then .content else null end)] | map(strings | test($search; "i")) | any) | '
  fi

  JQ_PROG+='
    {
      id: (.id | split("/") | last),
      title: .title,
      source: .origin.title,
      url: (.canonical[0].href // .alternate[0].href // ""),
      published: (.published | todate),
      categories: [.categories[] | select(contains("/label/")) | split("/label/")[1]]
    } |
    "[\(.published)] [\(.source)] \(.title)\n  ID: \(.id)\n  URL: \(.url)\n  Categories: \(.categories | join(", "))\n"'

  echo "$RESPONSE" | jq "${JQ_ARGS[@]}" "$JQ_PROG" 2>/dev/null || echo "No articles found or error parsing response" >&2
}

cmd_mark_read() {
  local ITEM_ID="$1"
  if [ -z "$ITEM_ID" ]; then
    echo "Error: article ID required" >&2
    exit 1
  fi
  auth_login
  local TOKEN=$(api_get "token")
  api_post "edit-tag" -d "T=$TOKEN" -d "a=user/-/state/com.google/read" -d "i=$ITEM_ID" > /dev/null
  echo "Marked article as read."
}

cmd_star() {
  local ITEM_ID="$1"
  if [ -z "$ITEM_ID" ]; then
    echo "Error: article ID required" >&2
    exit 1
  fi
  auth_login
  local TOKEN=$(api_get "token")
  api_post "edit-tag" -d "T=$TOKEN" -d "a=user/-/state/com.google/starred" -d "i=$ITEM_ID" > /dev/null
  echo "Starred article."
}

cmd_unstar() {
  local ITEM_ID="$1"
  if [ -z "$ITEM_ID" ]; then
    echo "Error: article ID required" >&2
    exit 1
  fi
  auth_login
  local TOKEN=$(api_get "token")
  api_post "edit-tag" -d "T=$TOKEN" -d "r=user/-/state/com.google/starred" -d "i=$ITEM_ID" > /dev/null
  echo "Unstarred article."
}

# --- Main ---
COMMAND="${1:-headlines}"
shift 2>/dev/null || true

case "$COMMAND" in
  headlines|news|latest) cmd_headlines "$@" ;;
  categories|cats) cmd_categories ;;
  feeds) cmd_feeds ;;
  mark-read) cmd_mark_read "$1" ;;
  star) cmd_star "$1" ;;
  unstar) cmd_unstar "$1" ;;
  *)
    echo "Usage: $0 {headlines|categories|feeds|mark-read|star|unstar}" >&2
    echo "" >&2
    echo "  headlines [--count N] [--hours N] [--category NAME] [--feed ID] [--search TEXT] [--starred] [--unread]" >&2
    echo "  categories        List all categories" >&2
    echo "  feeds             List all feeds" >&2
    echo "  mark-read <id>    Mark an article as read" >&2
    echo "  star <id>         Star an article" >&2
    echo "  unstar <id>       Unstar an article" >&2
    exit 1
    ;;
esac
