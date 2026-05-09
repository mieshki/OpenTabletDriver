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

echo "Building OpenTabletDriver (Linux)..."
dotnet build OpenTabletDriver.Linux.slnf
echo "Build complete."
