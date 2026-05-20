extends SceneTree
## tests/test_runner.gd — aggregating project test runner.
##
## Discovers every `res://tests/test_*.gd` script other than this runner and
## the smoke test, spawns each one as its own `godot --headless --script ...`
## invocation, captures the child exit code, and aggregates the results.
##
## Contract:
##   - exit 0  iff at least one test was discovered AND every child exited 0.
##   - exit 1  if one or more child tests exited non-zero.
##   - exit 2  if zero tests were discovered (treated as a runner failure —
##             a "no tests" green is the exact false-green class this runner
##             exists to prevent).
##
## Smoke is excluded on purpose: `tests/test_smoke.gd` is invoked separately
## by the AGENTS.md build invariants. Running it twice in CI is wasted work,
## and a smoke crash should still surface there.
##
## Visual tests (test_visual_capture, test_visual_smoke) self-skip under the
## headless DisplayServer and exit 0; they are kept in the discovery set so
## that under a render-capable run they participate in the aggregate.
##
## Owner: QA role.
## Run:   godot --headless --path godot --script tests/test_runner.gd

const TESTS_DIR: String = "res://tests/"
const SELF_NAME: String = "test_runner.gd"
const SMOKE_NAME: String = "test_smoke.gd"

## Tail of child stdout/stderr to echo on failure, in lines.
## Session 46 raised this to 200 to survive dialogue-catalogue push_error spam
## that drowned real test output. After the catalogue cleanup (Session 46 close —
## ~13 draft-duplicate dialogue files removed from data/dialogues/), 60 lines is
## sufficient for any failing test's own assertion output. Raise again only if
## a future failing test routinely emits more than ~60 lines of diagnostic.
const FAILURE_TAIL_LINES: int = 60


func _init() -> void:
	var tests: Array[String] = _discover_tests()

	if tests.is_empty():
		printerr("[TestRunner] FAIL: zero tests discovered under %s — refusing to exit 0." % TESTS_DIR)
		quit(2)
		return

	var godot_bin: String = OS.get_executable_path()
	if godot_bin == "":
		printerr("[TestRunner] FAIL: OS.get_executable_path() returned empty; cannot spawn children.")
		quit(2)
		return

	var project_path: String = ProjectSettings.globalize_path("res://")

	print("[TestRunner] Discovered %d focused test(s) under %s." % [tests.size(), TESTS_DIR])
	print("[TestRunner] Godot binary: %s" % godot_bin)
	print("[TestRunner] Project path: %s" % project_path)
	print("")

	var passed: int = 0
	var failed: int = 0
	var failed_names: Array[String] = []
	var start_msec: int = Time.get_ticks_msec()

	for test_name in tests:
		var script_arg: String = "tests/" + test_name
		var child_log_path: String = "/tmp/pig_swine_runner_child_%s.log" % test_name.get_basename()
		var args: PackedStringArray = PackedStringArray([
			"--headless",
			"--path", project_path,
			"--log-file", child_log_path,
			"--script", script_arg,
		])
		var output: Array = []
		var test_start: int = Time.get_ticks_msec()
		var code: int = OS.execute(godot_bin, args, output, true, false)
		var elapsed_msec: int = Time.get_ticks_msec() - test_start

		if code == 0:
			passed += 1
			print("  PASS  [%5d ms] %s" % [elapsed_msec, test_name])
		else:
			failed += 1
			failed_names.append(test_name)
			printerr("  FAIL  [%5d ms] %s (exit %d)" % [elapsed_msec, test_name, code])
			_print_child_tail(output)

	var total: int = passed + failed
	var total_msec: int = Time.get_ticks_msec() - start_msec

	print("")
	print("[TestRunner] Summary: %d/%d passed in %d ms." % [passed, total, total_msec])

	if failed > 0:
		printerr("[TestRunner] FAIL: %d test(s) failed:" % failed)
		for name in failed_names:
			printerr("    - %s" % name)
		quit(1)
		return

	print("[TestRunner] ALL PASS.")
	quit(0)


## Enumerate non-self, non-smoke `test_*.gd` files in `res://tests/`, sorted.
func _discover_tests() -> Array[String]:
	var found: Array[String] = []
	var dir: DirAccess = DirAccess.open(TESTS_DIR)
	if dir == null:
		printerr("[TestRunner] DirAccess.open failed for %s" % TESTS_DIR)
		return found
	dir.list_dir_begin()
	while true:
		var entry: String = dir.get_next()
		if entry == "":
			break
		if dir.current_is_dir():
			continue
		if not entry.begins_with("test_"):
			continue
		if not entry.ends_with(".gd"):
			continue
		if entry == SELF_NAME or entry == SMOKE_NAME:
			continue
		found.append(entry)
	dir.list_dir_end()
	found.sort()
	return found


## OS.execute() appends combined stdout+stderr to `output` as a single String
## element. Print only the last `FAILURE_TAIL_LINES` lines so a noisy failing
## child does not flood the runner output.
func _print_child_tail(output: Array) -> void:
	if output.is_empty():
		printerr("    (no child output captured)")
		return
	var blob: String = str(output[0])
	if blob.strip_edges() == "":
		printerr("    (child output was empty)")
		return
	var lines: PackedStringArray = blob.split("\n", false)
	var start_idx: int = max(0, lines.size() - FAILURE_TAIL_LINES)
	for i in range(start_idx, lines.size()):
		printerr("    | %s" % lines[i])
