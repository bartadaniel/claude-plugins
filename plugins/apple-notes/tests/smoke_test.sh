#!/bin/bash
# Smoke test for apple-notes skill
# Runs full lifecycle against a disposable test folder
# Usage: bash tests/smoke_test.sh

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "$0")/../skills/apple-notes/scripts" && pwd)"
TEST_FOLDER="_test-apple-notes-skill"
PASS=0
FAIL=0
TOTAL=0

pass() {
  PASS=$((PASS + 1))
  TOTAL=$((TOTAL + 1))
  echo "  PASS: $1"
}

fail() {
  FAIL=$((FAIL + 1))
  TOTAL=$((TOTAL + 1))
  echo "  FAIL: $1 — $2"
}

cleanup() {
  echo ""
  echo "Cleaning up test folder..."
  bash "$SCRIPTS_DIR/remove_folder.sh" "$TEST_FOLDER" 2>/dev/null || true
}
trap cleanup EXIT

echo "=== Apple Notes Smoke Test ==="
echo ""

# 1. List accounts
echo "[1/13] List accounts"
ACCOUNTS=$(bash "$SCRIPTS_DIR/list_accounts.sh" 2>&1)
if echo "$ACCOUNTS" | grep -q '"name"'; then
  pass "list_accounts"
else
  fail "list_accounts" "$ACCOUNTS"
fi

# 2. List folders
echo "[2/13] List folders"
FOLDERS=$(bash "$SCRIPTS_DIR/list_folders.sh" 2>&1)
if echo "$FOLDERS" | grep -q 'Notes'; then
  pass "list_folders"
else
  fail "list_folders" "$FOLDERS"
fi

# 3. Create test folder
echo "[3/13] Create test folder"
RESULT=$(bash "$SCRIPTS_DIR/add_folder.sh" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"created"'; then
  pass "add_folder"
else
  fail "add_folder" "$RESULT"
fi

# 4. Create a note
echo "[4/13] Create note"
RESULT=$(bash "$SCRIPTS_DIR/add_note.sh" "Test Note Alpha" "This is test content" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"created"'; then
  pass "add_note"
else
  fail "add_note" "$RESULT"
fi

# Give Notes a moment to sync
sleep 2

# 5. List notes in folder
echo "[5/13] List notes in test folder"
NOTES=$(bash "$SCRIPTS_DIR/list_notes.sh" "" "$TEST_FOLDER" 2>&1)
if echo "$NOTES" | grep -q 'Test Note Alpha'; then
  pass "list_notes"
else
  fail "list_notes" "$NOTES"
fi

# 6. Get note content
echo "[6/13] Get note content"
BODY=$(bash "$SCRIPTS_DIR/get_note.sh" "Test Note Alpha" "" "$TEST_FOLDER" 2>&1)
if echo "$BODY" | grep -q 'test content'; then
  pass "get_note"
else
  fail "get_note" "$BODY"
fi

# 7. Update note
echo "[7/13] Update note"
RESULT=$(bash "$SCRIPTS_DIR/update_note.sh" "Test Note Alpha" "<div><h1>Test Note Alpha</h1></div><div>Updated content</div>" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"updated"'; then
  pass "update_note"
else
  fail "update_note" "$RESULT"
fi

# 8. Add tags
echo "[8/13] Add tags"
sleep 1
RESULT=$(bash "$SCRIPTS_DIR/add_tags.sh" "Test Note Alpha" "test,smoke" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"tags_added"'; then
  pass "add_tags"
else
  fail "add_tags" "$RESULT"
fi

# 9. Search notes
echo "[9/13] Search notes"
RESULT=$(bash "$SCRIPTS_DIR/search_notes.sh" "Test Note" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q 'Test Note Alpha'; then
  pass "search_notes"
else
  fail "search_notes" "$RESULT"
fi

# 10. Rename tag
echo "[10/13] Rename tag"
RESULT=$(bash "$SCRIPTS_DIR/rename_tag.sh" "smoke" "verified" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"renamed"'; then
  pass "rename_tag"
else
  fail "rename_tag" "$RESULT"
fi

# 11. Remove tags
echo "[11/13] Remove tags"
RESULT=$(bash "$SCRIPTS_DIR/remove_tags.sh" "Test Note Alpha" "test,verified" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"tags_removed"'; then
  pass "remove_tags"
else
  fail "remove_tags" "$RESULT"
fi

# 12. Delete note
echo "[12/13] Delete note"
RESULT=$(bash "$SCRIPTS_DIR/delete_note.sh" "Test Note Alpha" "" "$TEST_FOLDER" 2>&1)
if echo "$RESULT" | grep -q '"status":"deleted"'; then
  pass "delete_note"
else
  fail "delete_note" "$RESULT"
fi

# 13. Rename folder (create a second folder to test with)
echo "[13/13] Rename folder"
bash "$SCRIPTS_DIR/add_folder.sh" "${TEST_FOLDER}-rename" >/dev/null 2>&1
RESULT=$(bash "$SCRIPTS_DIR/rename_folder.sh" "${TEST_FOLDER}-rename" "${TEST_FOLDER}-renamed" 2>&1)
if echo "$RESULT" | grep -q '"status":"renamed"'; then
  pass "rename_folder"
  bash "$SCRIPTS_DIR/remove_folder.sh" "${TEST_FOLDER}-renamed" 2>/dev/null || true
else
  fail "rename_folder" "$RESULT"
  bash "$SCRIPTS_DIR/remove_folder.sh" "${TEST_FOLDER}-rename" 2>/dev/null || true
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
exit $FAIL
