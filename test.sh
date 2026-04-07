#!/bin/sh
# test.sh — Exercise every SaaS endpoint
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE="$SCRIPT_DIR/bonfyre/cmd"

AUTH="$BONFYRE/BonfyreAuth/bonfyre-auth"
GATE="$BONFYRE/BonfyreGate/bonfyre-gate"
METER="$BONFYRE/BonfyreMeter/bonfyre-meter"
PAY="$BONFYRE/BonfyrePay/bonfyre-pay"

echo "╔══════════════════════════════════════════════════════╗"
echo "║     Bonfyre SaaS Stack — Test Suite                  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0

run_test() {
    DESC="$1"
    shift
    printf "  %-40s" "$DESC"
    if "$@" > /dev/null 2>&1; then
        echo "✓"
        PASS=$((PASS + 1))
    else
        echo "✗"
        FAIL=$((FAIL + 1))
    fi
}

# Auth tests
run_test "auth: signup new user" \
    "$AUTH" signup --email test-$$@example.com --password test123

run_test "auth: login" \
    "$AUTH" login --email test-$$@example.com --password test123

run_test "auth: status check" \
    "$AUTH" status

# Gate tests
run_test "gate: issue free key" \
    "$GATE" issue --email test-$$@example.com --tier free

run_test "gate: issue pro key" \
    "$GATE" issue --email test-$$@example.com --tier pro

run_test "gate: status check" \
    "$GATE" status

# Meter tests
run_test "meter: record usage" \
    "$METER" record --email test-$$@example.com --op embed --count 10

run_test "meter: check status" \
    "$METER" status

# Pay tests
run_test "pay: generate invoice" \
    "$PAY" invoice --user-id 1 --period 2026-04

run_test "pay: status check" \
    "$PAY" status

echo ""
echo "  Results: $PASS passed, $FAIL failed"
echo ""

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
