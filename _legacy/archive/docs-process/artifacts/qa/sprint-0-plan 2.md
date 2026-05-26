# QA Browser Subagent Test Plan — Sprint 0

This document outlines the exact runtime checks the Antigravity browser subagent must perform to verify the Pig & Swine RPG build after Sprint 0 wiring completes.

## Goal
Verify that the foundational systems (room transitions, chapter 1 state shape, and save migration) integrated during Sprint 0 function flawlessly in a live game environment.

## Preconditions
- Local development server is running (`npm run dev` or `vite dev`).
- The browser subagent has successfully loaded the application (`http://localhost:5173` or equivalent).
- `localStorage` is cleared before starting to ensure a clean state.

## Runtime Execution Steps

### 1. Initialization and Overworld Loading
- **Action:** Click or press Space to bypass the title screen.
- **Verification:** Ensure the main overworld map renders correctly without console errors, and the player character is controllable.

### 2. Room Transition System Check
- **Action:** Navigate the player character to the Pig & Swine Office door and enter.
- **Verification:** Confirm the fade-to-black room transition executes smoothly and the interior room (Office) is rendered instead of the overworld.
- **Action:** Exit the office, travel to the Court building, and enter.
- **Verification:** Confirm the transition works again and the Court interior distinctively loads.

### 3. Quest Flags and Dialogue State Activation
- **Action:** Return to the Pig & Swine Office and interact with Mr. Pig.
- **Verification:** Verify that the "pigRevealedCrisis" dialogue path triggers correctly.
- **Action:** Find and interact with Muraś.
- **Verification:** Verify that the dialogue advances the quest state (directs to the law binder).

### 4. Save/Load Round-Trip Validation
- **Action:** Press the Save key (usually `S`).
- **Verification:** Ensure the UI confirms the save (e.g., "Game Saved!" flash message).
- **Action:** Refresh the browser page completely to reset the runtime state.
- **Action:** Press the Load key (usually `L`).
- **Verification:** The player character must appear exactly where they were saved (inside the Office).
- **Action:** Interact with Muraś again.
- **Verification:** Muraś should recognize that the player is already on the step to find the law binder (validating that `chapter1` quest flags were restored).

### 5. Media Capture Requirements
- Take a **Screenshot** of the Overworld.
- Take a **Screenshot** of the Office interior during dialogue.
- Take a **Screenshot** immediately after loading the saved game.
- Capture a **Video Recording** of the full playthrough session.

## Acceptance Criteria
- Zero runtime JavaScript exceptions in the console.
- Save/Load completely restores `room.current`, player coordinates, and `chapter1` state fields.
- Room transitions never leave the player trapped out-of-bounds or stuck in a black screen.
