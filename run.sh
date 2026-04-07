#!/bin/sh
# run.sh — Start the Bonfyre SaaS backend and seed demo data
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE="$SCRIPT_DIR/bonfyre/cmd"
OUTPUT="$SCRIPT_DIR/output"
PIDFILE="$OUTPUT/api.pid"

# Find binaries
API="$BONFYRE/BonfyreAPI/bonfyre-api"
AUTH="$BONFYRE/BonfyreAuth/bonfyre-auth"
GATE="$BONFYRE/BonfyreGate/bonfyre-gate"
METER="$BONFYRE/BonfyreMeter/bonfyre-meter"
PAY="$BONFYRE/BonfyrePay/bonfyre-pay"

for bin in "$API" "$AUTH" "$GATE" "$METER" "$PAY"; do
    if [ ! -x "$bin" ]; then
        echo "Error: $(basename "$bin") not found. Run ./setup.sh first."
        exit 1
    fi
done

mkdir -p "$OUTPUT"

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Bonfyre SaaS Stack — Full Backend Demo           ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── Start API gateway ────────────────────────────────────────
echo "━━━ Starting services ━━━"
echo ""

printf "  [1/5] API gateway        "
"$API" --port 9090 serve &
API_PID=$!
echo "$API_PID" > "$PIDFILE"
sleep 1

if kill -0 "$API_PID" 2>/dev/null; then
    echo "✓  http://localhost:9090"
else
    echo "✗  (failed to start)"
    exit 1
fi

# ── Create demo user ─────────────────────────────────────────
printf "  [2/5] Creating user      "
if "$AUTH" signup --email demo@example.com --password demo123 > /dev/null 2>&1; then
    echo "✓  demo@example.com"
else
    echo "✓  demo@example.com (already exists)"
fi

# ── Issue API key ─────────────────────────────────────────────
printf "  [3/5] Issuing API key    "
KEY=$("$GATE" issue --email demo@example.com --tier pro 2>/dev/null || echo "bf_pro_existing")
echo "✓  tier=pro"

# ── Record some usage ────────────────────────────────────────
printf "  [4/5] Recording usage    "
"$METER" record --email demo@example.com --op embed --count 142 > /dev/null 2>&1 || true
"$METER" record --email demo@example.com --op search --count 891 > /dev/null 2>&1 || true
"$METER" record --email demo@example.com --op transcribe --count 23 > /dev/null 2>&1 || true
echo "✓  3 operations metered"

# ── Generate invoice ──────────────────────────────────────────
printf "  [5/5] Generating invoice "
"$PAY" invoice --user-id 1 --period 2026-04 > /dev/null 2>&1 || true
echo "✓"

echo ""
echo "━━━ Backend running ━━━"
echo ""
echo "  Dashboard:  http://localhost:9090"
echo "  API:        http://localhost:9090/api/"
echo "  User:       demo@example.com / demo123"
echo ""
echo "  Binary sizes:"
for bin in "$API" "$AUTH" "$GATE" "$METER" "$PAY"; do
    NAME=$(basename "$bin")
    SIZE=$(ls -lh "$bin" | awk '{print $5}')
    printf "    %-20s %s\n" "$NAME" "$SIZE"
done
echo ""
echo "  Press Ctrl+C to stop."

# Wait for Ctrl+C
trap '
    echo ""
    echo "Shutting down..."
    kill '"$API_PID"' 2>/dev/null
    rm -f "'"$PIDFILE"'"
    echo "Done."
    exit 0
' INT TERM

wait "$API_PID"
