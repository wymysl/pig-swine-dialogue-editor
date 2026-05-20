GODOT ?= godot
PYTHON ?= python3
NODE ?= node

.PHONY: verify verify-data verify-godot install-hooks

verify: verify-data verify-godot

verify-data:
	$(PYTHON) tools/voice_audit.py godot/data/voice_references/
	$(NODE) tools/verify_dialogue_roundtrip.js

verify-godot:
	$(GODOT) --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_swine_smoke.log
	$(GODOT) --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_swine_runner.log

install-hooks:
	mkdir -p .git/hooks
	cp tools/hooks/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
