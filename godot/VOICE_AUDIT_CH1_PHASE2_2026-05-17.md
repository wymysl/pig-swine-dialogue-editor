# Chapter 1 Voice Reference Audit — Phase 2 Coverage
**Date:** 2026-05-17  
**Session:** Daily Standup Task 3

## Summary
Chapter 1 has voice references for all core speakers, but **Phase 2 (post-court) dialogue content is missing or incomplete** for several key characters. This gap will block Phase 2 dialogue finalization until voice profiles are extended.

## Chapter 1 Core Speakers — Coverage Status

### Primary Team (Phase 1 ✓ | Phase 2 ?)

| Speaker | File | Lines | Status | Phase 2 Gap |
|---------|------|-------|--------|------------|
| **Dr. A. Cula** | dialogue_samples_dr_a_cula.jsonl | 211 | ✓ Complete | Generic office; needs post-verdict internal reaction |
| **Murrow** | dialogue_samples_mr_murrow.jsonl | 349 | ✓ Phase 1 Strong | **Missing Phase 2 closing/reflection lines** — needs post-court response to verdicts + remedies |
| **Crab** | dialogue_samples_crab.jsonl | 295 | ✓ Phase 1 Strong | **Missing Phase 2 post-court analysis** — needs verdict-specific factual commentary |
| **Whimsy** | dialogue_samples_whimsy.jsonl | 323 | ✓ Phase 1 Strong | **Missing Phase 2 post-court reaction** — needs outcome-keyed theatrical response + remedy reaction |
| **Asia** | dialogue_samples_asia.jsonl | 213 | ✓ Complete | Generic; can reuse Phase 1 hints for post-court |

### External Speakers (Phase 1 ✓ | Phase 2 ?)

| Speaker | File | Lines | Status | Phase 2 Gap |
|---------|------|-------|--------|------------|
| **Judge (District Court)** | dialogue_samples_judge_district_court_judge.jsonl | 597 | ✓ Phase 1 Rich | **Missing Phase 2 remedy reactions** — needs judge responses to chosen remedy + judicial patience signals |
| **Halina (Client)** | dialogue_samples_halina_sikorska.jsonl | 41 | ⚠️ Minimal | **Severely incomplete** — only 41 lines; needs Phase 2 post-verdict relief/reaction + remedy reaction |
| **Barista** | dialogue_samples_barista.jsonl | 634 | ✓ Rich | Generic office; can reuse for post-court coffee scenes |
| **Landlord Counsel** | dialogue_samples_landlord_counsel_ch1.jsonl | 2 | ❌ Stub | **Critical gap** — only 2 lines (metadata?); needs Phase 2 post-verdict reaction + closing prep |

## Phase 2 Dialogue Content Needs

### By Speaker

**Judge District Court:**
- [ ] Post-verdict reactions (strong outcome: acknowledgment of coherence)
- [ ] Post-verdict reactions (standard outcome: modest approval)
- [ ] Post-verdict reactions (narrow outcome: technical constraint recognition)
- [ ] Post-verdict reactions (blunder recovery: surprise recovery acknowledgment)
- [ ] Remedy reaction flavor lines (procedural reset acceptance, merits dismissal resistance, etc.)
- [ ] Judicial patience / patience-exhaustion cues

**Murrow:**
- [ ] Post-court closing reflection (what the victory/loss means for the firm)
- [ ] Remedy assessment (proportionality of chosen remedy vs. argument strength)
- [ ] Next-steps framing (sets up Beat 13 payoff or Chapter 2 setup)

**Crab:**
- [ ] Post-court document assessment (what the verdict says about the paper trail)
- [ ] Evidence sufficiency reflection (which evidence was decisive, which was decorative)
- [ ] Opposing counsel's record reaction (how badly the landlord counsel's file collapsed, if applicable)

**Whimsy:**
- [ ] Post-court theatrical celebration (strong outcome) or theatrical commiseration (loss/blunder)
- [ ] Fair-hearing victory flavor (if strong outcome emphasizes procedural fairness)
- [ ] Remedy posture (rhetorical angle on chosen remedy)

**Halina (Client):**
- [ ] Post-verdict relief / shock reaction (case outcome)
- [ ] Remedy acceptance / disappointment (did we get what she needed?)
- [ ] Future confidence (sets up potential Chapter 2 referral or closure)

**Landlord Counsel:**
- [ ] Post-verdict reaction (defeat acknowledgment or narrow loss protest)
- [ ] Remedy reaction (if dismissal, acknowledgment; if procedural reset, protest)

## Recommendation

**Immediate action:** Expand phase 2 voice references for Murrow, Crab, Whimsy, Judge, and Halina before Design finalizes post-court dialogue in data/judge_reactions_ch1.json and phase-2 states in dialogue/*.json files.

**Priority order:**
1. Judge district court (drives entire Phase 2 structure)
2. Murrow + Crab + Whimsy (team reaction balance)
3. Halina (client closure)
4. Landlord counsel (opponent closure)

**Timeline:** Phase 2 dialogue authoring can begin once voice profiles are extended with 5-10 lines per outcome path per character. This unblocks judge_reactions_ch1.json finalization and Phase 2 state drafting in crab.json / murrow.json / whimsy.json.
