# Rule B Audit — story.txt and dialogue_samples.txt

Date: 2026-05-04
Total quoted lines scanned: 76
CLEAN: 67
VIOLATION: 9
POSSIBLE TIMING: 0
UNCLEAR SPEAKER: 0

---

## VIOLATION (clearly wrong, fix proposed)

All nine violations are the same pattern: **Asia** addresses Murrow as **"Murrow"** (bare surname) when the rule requires every non-inner-circle speaker to say **"Mr. Murrow"**. Asia is the front-desk secretary; she is not Dr. A. Cula, Crab, or Whimsy, so she must use "Mr. Murrow".

| File | Line | Speaker | Scene | Quoted line | Proposed fix |
|---|---|---|---|---|---|
| dialogue_samples.txt | 51 | Asia | Ch 1, post-crisis hint state | `"Murrow will know what the case is actually about. He's somewhere between the files and disappointment."` | `"Mr. Murrow will know what the case is actually about. He's somewhere between the files and disappointment."` |
| dialogue_samples.txt | 56 | Asia | Ch 1, pre-court hint state | `"Murrow should check the case before court. He has a special face for missing documents."` | `"Mr. Murrow should check the case before court. He has a special face for missing documents."` |
| dialogue_samples.txt | 57 | Asia | Ch 1, court-ready hint state | `"If Murrow says you're ready, go north to the District Court. And maybe drink water."` | `"If Mr. Murrow says you're ready, go north to the District Court. And maybe drink water."` |
| dialogue_samples.txt | 150 | Asia | Ch 5, Team Assembly hint state | `"Murrow opened the Team Assembly board. Assign the right people to the right legal points. Please do not assign Mr. Pig to procurement."` | `"Mr. Murrow opened the Team Assembly board. Assign the right people to the right legal points. Please do not assign Mr. Pig to procurement."` |
| dialogue_samples.txt | 238 | Asia | Ch 2, evidence-board hint state | `"Murrow wants the evidence organised on the board. He gets twitchy around unstructured justice."` | `"Mr. Murrow wants the evidence organised on the board. He gets twitchy around unstructured justice."` |
| dialogue_samples.txt | 239 | Asia | Ch 2, readiness-check hint state | `"Ask Murrow for the readiness check. He'll tell you what the case is still missing."` | `"Ask Mr. Murrow for the readiness check. He'll tell you what the case is still missing."` |
| dialogue_samples.txt | 337 | Asia | Ch 3, urgent-filing hint state | `"Murrow is preparing the filing. Crab is checking the route. Whimsy is being kept away from the cover page."` | `"Mr. Murrow is preparing the filing. Crab is checking the route. Whimsy is being kept away from the cover page."` |
| dialogue_samples.txt | 422 | Asia | Ch 4, airport hint state | `"The customs form matters. Murrow says intent sometimes hides in boring boxes."` | `"The customs form matters. Mr. Murrow says intent sometimes hides in boring boxes."` |
| dialogue_samples.txt | 428 | Asia | Ch 4, Dual Attorney hint state | `"Murrow wants you to prepare the Dual Attorney board. Dr. A. Cula handles law; Mr. Swine handles facts, when facts survive him."` | `"Mr. Murrow wants you to prepare the Dual Attorney board. Dr. A. Cula handles law; Mr. Swine handles facts, when facts survive him."` |

---

## POSSIBLE TIMING (Crab/Whimsy + Cula address; needs human eyes)

*None found.* No Crab or Whimsy lines with "Cula" or "Dr. A. Cula" addresses appear as explicit quoted speech in either file. All Crab and Whimsy dialogue is marked `(see dialogue_samples.txt ...)` in story.txt, and dialogue_samples.txt contains no attributed Crab or Whimsy sample lines referencing Cula by name.

---

## UNCLEAR SPEAKER (do not auto-fix)

*None found.* Every quoted line had a clearly identifiable speaker from a section heading (`### Mr. Pig`, `### Asia`, etc.), an inline label ("Old woman:", "Court clerk NPC:", "Missing rights memo:", etc.), or the surrounding Asia hint-state logic block.

---

## Notes on scope

### story.txt
story.txt is almost entirely narration, spec prose, GDScript blocks, evidence descriptions, and `(see dialogue_samples.txt ...)` placeholders. After scanning all 6,581 lines, **zero standalone character speech lines** were found that are not already delegated to dialogue_samples.txt. The only blockquote strings in story.txt are item/evidence descriptions (narration), docket-board and printer output strings (sign text), and legal/comedy spine summaries (narration). Rule B does not apply to any of these; none were counted as dialogue lines and none were flagged.

### Mr. Pig lines (dialogue_samples.txt lines 13–17) — control check
Mr. Pig correctly uses "Mr. Murrow" in lines 13 and 17. Both CLEAN. This confirms the error is specific to Asia's hint-state block, not a global find-replace failure.

### "Dr. A. Cula" address in Asia line 428
The same line that violates Murrow-address also contains "Dr. A. Cula" (referring to the player) — that address is **correct** per Rule B. Only the Murrow form is wrong.

### "Dr. Cula" (without A.)
No instance of the forbidden form "Dr. Cula" (without the A.) appears anywhere in either file. ✅

---

## Summary

Both files are **highly compliant** with Rule B. The entire violation cluster is a single recurring error: Asia's repeatable-hint lines use bare **"Murrow"** nine times across her hint-state sequences for Chapters 1–5. The pattern is consistent across every chapter's hint block, strongly suggesting the hints were drafted before or independently of the Rule B address constraint.

The fix is mechanical and low-risk: substitute `"Mr. Murrow"` for `"Murrow"` in exactly nine lines of **dialogue_samples.txt** (lines 51, 56, 57, 150, 238, 239, 337, 422, 428). story.txt requires no edits.

**Recommended next pass:** when authoring `data/dialogues/dialogues.json` from these samples, run a Rule B gate at JSON authoring time per AGENTS.md. Asia's hint lines should be the first test case. Additionally, any Crab or Whimsy lines that use "Cula" (post-recruitment shortform) should be verified against the chapter-recruitment-state flag before being committed.
