#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v dotnet &> /dev/null; then
    for nix_path in /nix/store/*dotnet-sdk*/share/dotnet; do
        if [ -x "$nix_path/dotnet" ]; then
            export PATH="$nix_path:$PATH"
            break
        fi
    done
fi

if ! command -v dotnet &> /dev/null; then
    echo "ERROR: dotnet not found in PATH or /nix/store. Install .NET 8 SDK first." >&2
    exit 1
fi

DOTNET_PATH=$(command -v dotnet)
if [[ "$DOTNET_PATH" == /nix/store/* ]]; then
    REPO_LIB_DIR="./.local/lib"
    if [ ! -f "$REPO_LIB_DIR/libudev.so.1" ] && [ -f /lib/x86_64-linux-gnu/libudev.so.1 ]; then
        echo "Setting up libudev workaround for Nix dotnet runtime..."
        mkdir -p "$REPO_LIB_DIR"
        cp -L /lib/x86_64-linux-gnu/libudev.so.1 "$REPO_LIB_DIR/"
        for lib in $(ldd /lib/x86_64-linux-gnu/libudev.so.1 | awk '/=> \// {print $3}'); do
            case "$lib" in
                */libc.so*|*/ld-linux*|*/libpthread*|*/libdl.so*|*/libm.so*|*/librt.so*|*/libgcc_s*) ;;
                *) cp -L "$lib" "$REPO_LIB_DIR/" 2>/dev/null || true ;;
            esac
        done
    fi
    if [ -f /lib/x86_64-linux-gnu/libevdev.so.2 ] && [ ! -f "$REPO_LIB_DIR/libevdev.so.2" ]; then
        cp -L /lib/x86_64-linux-gnu/libevdev.so.2 "$REPO_LIB_DIR/"
    fi
    if [ -f "$REPO_LIB_DIR/libudev.so.1" ]; then
        export LD_LIBRARY_PATH="$REPO_LIB_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    fi
fi

echo "Starting OpenTabletDriver daemon..."
dotnet run --project OpenTabletDriver.Daemon
