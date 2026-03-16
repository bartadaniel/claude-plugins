#!/bin/bash
# Delete a folder from Apple Notes
# Usage: bash remove_folder.sh <folder_name> [account]
# Notes in the folder are moved to Recently Deleted

FOLDER_NAME="${1:?Error: folder name is required}"
ACCOUNT="${2:-}"

osascript -l JavaScript - "$FOLDER_NAME" "$ACCOUNT" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const folderName = argv[0];
    const account = argv[1];

    let folder;
    if (account) {
      folder = app.accounts.byName(account).folders.byName(folderName);
    } else {
      folder = app.folders.byName(folderName);
    }

    app.delete(folder);
    return JSON.stringify({status: 'deleted', folder: folderName});
  }
EOF
