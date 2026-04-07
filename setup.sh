#!/bin/sh
# setup.sh — Clone Bonfyre and build the 6 SaaS-stack binaries
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BONFYRE_DIR="$SCRIPT_DIR/bonfyre"

if [ -d "$BONFYRE_DIR" ] && [ -f "$BONFYRE_DIR/Makefile" ]; then
    echo "Bonfyre already cloned at $BONFYRE_DIR"
else
    echo "Cloning Bonfyre..."
    git clone https://github.com/Nickgonzales76017/bonfyre.git "$BONFYRE_DIR"
fi

echo ""
echo "Building SaaS stack binaries..."

cd "$BONFYRE_DIR"
make lib

SAAS_BINS="BonfyreAPI BonfyreAuth BonfyreGate BonfyreMeter BonfyrePay BonfyreCMS"
TOTAL_SIZE=0

for bin in $SAAS_BINS; do
    printf "  Building %-20s" "$bin..."
    if make -C "cmd/$bin" CC="${CC:-cc}" CFLAGS="${CFLAGS:--O3 -march=native -flto=auto -Wall -Wextra -std=c11}" > /dev/null 2>&1; then
        # Find the built binary
        BUILT=$(find "cmd/$bin" -maxdepth 1 -name 'bonfyre-*' -type f -perm +111 2>/dev/null | head -1)
        if [ -n "$BUILT" ]; then
            SIZE=$(ls -lh "$BUILT" | awk '{print $5}')
            echo "✓  ($SIZE)"
        else
            echo "✓"
        fi
    else
        echo "✗"
    fi
done

echo ""
echo "Setup complete. Run ./run.sh to start the backend."
