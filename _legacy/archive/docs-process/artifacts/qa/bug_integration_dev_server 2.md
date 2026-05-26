# Bug Report

**Target Persona:** Integration Agent  
**Severity:** P0 blocker  

## Description
The Antigravity browser subagent cannot launch the Vite dev server (`npm run dev`) or a Python `http.server` due to sandbox network constraints (`EPERM` / `Operation not permitted` on port binding).

## Reproduction Steps
1. Attempt to run `npm run dev` or `python3 -m http.server 5173`.
2. Observe `EPERM` error preventing the server from starting.

## Expected vs Actual
**Expected:** The development server starts successfully and is accessible by the browser subagent for runtime verification.
**Actual:** The server crashes with `Operation not permitted`, blocking all runtime QA verifications.
