extends SceneTree
## tests/test_runner.gd — GUT-compatible runner skeleton.
## Works even without GUT installed: prints "no tests yet" and exits 0.
## When GUT is added (via AssetLib or as an addon), replace this body
## with the standard GUT runner invocation per GUT's documentation.
##
## Owner: QA role (append-only; see AGENTS.md §File ownership).

func _init() -> void:
	print("[TestRunner] Pig & Swine RPG — sprint 1 skeleton.")
	print("[TestRunner] GUT not yet installed. No tests to run.")
	print("[TestRunner] Exit 0.")
	quit(0)
