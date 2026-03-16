#!/bin/bash
# List all folders in Apple Notes
# Usage: bash list_folders.sh [account]

ACCOUNT="${1:-}"

osascript -l JavaScript - "$ACCOUNT" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const account = argv[0];
    let folders;
    if (account) {
      folders = app.accounts.byName(account).folders();
    } else {
      folders = app.folders();
    }
    const result = folders.map(f => f.name());
    return JSON.stringify(result, null, 2);
  }
EOF
