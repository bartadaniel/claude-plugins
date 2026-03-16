#!/bin/bash
# List all Notes accounts
# Usage: bash list_accounts.sh

osascript -l JavaScript <<'EOF'
  function run() {
    const app = Application('Notes');
    const accounts = app.accounts();
    const result = accounts.map(a => ({
      name: a.name(),
      id: a.id()
    }));
    return JSON.stringify(result, null, 2);
  }
EOF
