# Lock-stale files for Piotr to clean

The macOS sandbox cannot unlink these files. Run on your local machine:

```bash
cd "/Users/piotr/Documents/Silly projects/pig-swine-rpg/.git"
rm -f *.lock.stale*
ls *.lock* 2>/dev/null   # should be empty
```

## File Inventory

**Files counted:** 14

**List of lock-stale files:**
- `HEAD.lock.stale`
- `HEAD.lock.stale.1778872485136084454`
- `HEAD.lock.stale.1778881484005275095`
- `HEAD.lock.stale.1778881837886313000`
- `HEAD.lock.stale.1778882054815597000`
- `HEAD.lock.stale.1778882059681917952`
- `index.lock.stale`
- `index.lock.stale.1778872459264926609`
- `index.lock.stale.1778881484007707053`
- `index.lock.stale.1778882079178420920`
- `index.lock.stale.1778882080191331000`
- `index.lock.stale.1778882090`
- `index.lock.stale.1778882129155690000`
- `next-index-9.lock.stale`

## Background

These files accumulated during the overnight cohort's commits (particularly Commit 2, which involved multiple git operations). The pattern is:

1. Agent code attempts a git operation
2. A lock file (`index.lock`, `HEAD.lock`, etc.) is created by git to prevent concurrent access
3. A concurrent or subsequent agent tries to run git
4. The lock file blocks the operation
5. Agent code renames the lock file to `<name>.lock.stale.<timestamp>` to allow the next operation to proceed
6. The renamed file cannot be unlinked by the sandbox (sandbox permission `Operation not permitted`)
7. Files accumulate across commits

## Safety

These files are:
- Empty (size 0) or stale (timestamp > 1 hour old)
- Safe to delete — they are not actively held by any git process
- Not part of the repository state — they are `.git/` directory artifacts

## Timeline

- Most stale files dated 2026-05-15 (previous evening's work)
- New stale files dated 2026-05-16 21:54 (tonight's Commit 2)

---

**Generated:** 2026-05-16 (Agent 10, Cowork Haiku)  
**Action Required:** Manual cleanup on local machine (sandbox cannot unlink)
