#!/bin/bash
# Nightly headless test runner. Invoked by launchd
# (com.piotr.pigswine.nightly-tests) before the Claude nightly-health-check
# task reads the results.
#
# Writes godot/nightly/<YYYY-MM-DD>/test_results.md.
# Exit status = number of failed tests (0 = all pass).
#
# Override the Godot binary by exporting GODOT_BIN before invocation.

set -u

REPO_DIR="${REPO_DIR:-$HOME/Documents/Silly projects/pig-swine-rpg}"
GODOT_DIR="$REPO_DIR/godot"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
DATE=$(date +%Y-%m-%d)
OUT_DIR="$GODOT_DIR/nightly/$DATE"
OUT_FILE="$OUT_DIR/test_results.md"

mkdir -p "$OUT_DIR"

if [ ! -x "$GODOT_BIN" ]; then
  {
    echo "# Headless Test Suite — $DATE"
    echo ""
    echo "FAILED TO START — Godot binary not found or not executable at \`$GODOT_BIN\`."
    echo "Set GODOT_BIN in the launchd plist or install Godot at the default path."
  } > "$OUT_FILE"
  exit 127
fi

{
  echo "# Headless Test Suite — $DATE"
  echo ""
  echo "- Godot: \`$GODOT_BIN\`"
  echo "- Started: $(date -Iseconds 2>/dev/null || date)"
  echo ""
  echo "| Test | Result | Note |"
  echo "|------|--------|------|"
} > "$OUT_FILE"

PASS=0
FAIL=0
FAILED_NAMES=()

for test_path in "$GODOT_DIR"/tests/test_*.gd; do
  [ -f "$test_path" ] || continue
  name=$(basename "$test_path" .gd)
  log="/tmp/pig_nh_${name}.log"
  rel="tests/${name}.gd"

  "$GODOT_BIN" --headless --path "$GODOT_DIR" --script "$rel" --log-file "$log" >/dev/null 2>&1
  rc=$?

  if [ $rc -eq 0 ]; then
    PASS=$((PASS+1))
    echo "| $name | PASS |  |" >> "$OUT_FILE"
  else
    FAIL=$((FAIL+1))
    FAILED_NAMES+=("$name")
    first_err=$(grep -E 'ERROR|SCRIPT ERROR|FAIL|Assertion|at:' "$log" 2>/dev/null | head -1 | tr '|' '/' | cut -c1-180)
    [ -z "$first_err" ] && first_err="(exit $rc; see $log)"
    echo "| $name | **FAIL** | $first_err |" >> "$OUT_FILE"
  fi
done

{
  echo ""
  echo "## Summary"
  echo ""
  echo "- Passed: $PASS"
  echo "- Failed: $FAIL"
  if [ $FAIL -gt 0 ]; then
    echo "- Failing tests: ${FAILED_NAMES[*]}"
  fi
  echo "- Finished: $(date -Iseconds 2>/dev/null || date)"
} >> "$OUT_FILE"

exit $FAIL
