# fanout_cula — patch candidates

Source: `godot/data/dialogues/cula.json` (75 states inspected)

## Summary

| target | count | already_present |
|---|---|---|
| `<ambient>` | 4 | 0 |
| `<stay>` | 2 | 0 |
| `<unresolved>` | 5 | 0 |
| `asia.json` | 6 | 1 |
| `crab.json` | 6 | 0 |
| `halina.json` | 14 | 0 |
| `judge_district_ch1.json` | 5 | 0 |
| `murrow.json` | 16 | 0 |
| `pig.json` | 8 | 1 |
| `postcard_swine_ch1.json` | 2 | 1 |
| `whimsy.json` | 7 | 1 |

## <ambient>

### [ ] `cula_b1_arrival_observation` (beat1)

- route: internal monologue without NPC anchor
- trigger: `!chapter1.met_pig`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "Pig & Swine. Attorneys, counselors, possibly open. That is not how they describe"
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b2_office_first_impression` (beat2)

- route: internal monologue without NPC anchor
- trigger: `!chapter1.met_asia && !chapter1.met_pig`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "Three file piles, one phone, one secretary, one panic from the back room.",
    "Somewhere in here there is a coffee machine making a noise I cannot yet classify"
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b8_office_return_internal` (beat8)

- route: internal monologue without NPC anchor
- trigger: `chapter1.recruited_whimsy == true && !chapter1.halina_arrived`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "The meeting room has a table the rest of the office cannot afford. That tells me"
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b9_kundera_beat` (beat9)

- route: internal monologue without NPC anchor
- trigger: `chapter1.archive_research_complete == true && !chapter1.court_ready`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "I notice that I do not yet know whether the firm is teaching me, or whether the "
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

## <stay>

### [ ] `family_photo_ch1` (None)

- route: preserved family-photo dispatch
- trigger: `!chapter1.viewed_family_photo`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "A family photo. Mr. Pig appears to be the youngest in it."
  ]
}
```

### [ ] `family_photo_ch1_repeat` (None)

- route: preserved family-photo dispatch
- trigger: `chapter1.viewed_family_photo == true`
- speaker: `cula`
- payload:
```json
{
  "silent": true
}
```

## <unresolved>

### [ ] `cula_b8_dwell_options` (beat8)

- route: no id-token, no NPC tag, no beat heuristic match
- trigger: `chapter1.halina_met == true && chapter1.client_meeting_stance != '' && !chapter1.halina_close_done && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(apartment)",
        "value": "cula_b8_dwell_apartment"
      },
      {
        "text": "(referral)",
        "value": "cula_b8_dwell_referral"
      },
      {
        "text": "(taught)",
        "value": "cula_b8_dwell_taught"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b9_archive_setup` (beat9)

- route: no id-token, no NPC tag, no beat heuristic match
- trigger: `chapter1.halina_close_done == true && !chapter1.archive_research_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Article 135-bis, paragraph two. The binder has been waiting for this clause all "
  ]
}
```

### [ ] `cula_b9_dwell_how_options` (beat9)

- route: no id-token, no NPC tag, no beat heuristic match
- trigger: `chapter1.has_law_binder == true && !chapter1.archive_research_complete && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(how found)",
        "value": "cula_b9_dwell_how_found"
      },
      {
        "text": "(used before)",
        "value": "cula_b9_dwell_used_before"
      },
      {
        "text": "(next)",
        "value": "cula_b9_dwell_next"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b9_archive_close` (beat9)

- route: no id-token, no NPC tag, no beat heuristic match
- trigger: `chapter1.archive_research_complete == true && !chapter1.court_ready`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Defective service under Article 135-bis. Motion to set aside, within fourteen da"
  ]
}
```

### [ ] `cula_b13_victory_internal` (beat13)

- route: no id-token, no NPC tag, no beat heuristic match
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "We won the part of the case that allows the case to exist. That feels appropriat"
  ]
}
```

## asia.json

### [x] `cula_b2_asia_greeting` (beat2)

- route: id-token 'asia'
- trigger: `!chapter1.met_asia`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Good morning. Dr. A. Cula. First day. I was told to ask for reception, coffee, o",
    "I see you have all three in motion. I will start with reception."
  ]
}
```
- already_present: trigger overlap with target state 'asia_b2_via_behind'

### [ ] `cula_b2_asia_dwell_options` (beat2)

- route: id-token 'asia'
- trigger: `chapter1.met_asia == true && !chapter1.met_pig && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(tenure)",
        "value": "cula_b2_asia_dwell_tenure"
      },
      {
        "text": "(today)",
        "value": "cula_b2_asia_dwell_today"
      },
      {
        "text": "(logistics)",
        "value": "cula_b2_asia_dwell_logistics"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b2_asia_dwell_tenure_reply` (beat2)

- route: id-token 'asia'
- trigger: `chapter1.state_choice == 'cula_b2_asia_dwell_tenure'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Before I start anything I should probably break: how long have you been holding "
  ],
  "once": true
}
```

### [ ] `cula_b2_asia_dwell_today_reply` (beat2)

- route: id-token 'asia'
- trigger: `chapter1.state_choice == 'cula_b2_asia_dwell_today'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Is it always like this, or have I picked a particularly loud morning?"
  ],
  "once": true
}
```

### [ ] `cula_b2_asia_dwell_logistics_reply` (beat2)

- route: id-token 'asia'
- trigger: `chapter1.state_choice == 'cula_b2_asia_dwell_logistics'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Practical question. Where do you keep the binder labels? The blue spines I keep "
  ],
  "once": true
}
```

### [ ] `cula_b13_asia_response` (beat13)

- route: id-token 'asia'
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Thanks, Asia. Whatever you are sorting, please do not let me add to the pile unt"
  ]
}
```

## crab.json

### [ ] `cula_b5_crab_recruitment_pitch` (beat5)

- route: id-token 'crab'
- trigger: `chapter1.has_law_binder == true && chapter1.met_murrow == true && !chapter1.met_crab`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Crab. I'm Cula.",
    "Sikorska eviction defense. The notice was served to old number seven; the buildi"
  ]
}
```

### [ ] `cula_b5_crab_dwell_options` (beat5)

- route: id-token 'crab'
- trigger: `chapter1.met_crab == true && !chapter1.recruited_crab && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(background)",
        "value": "cula_b5_crab_dwell_background"
      },
      {
        "text": "(why here)",
        "value": "cula_b5_crab_dwell_why_here"
      },
      {
        "text": "(case opinion)",
        "value": "cula_b5_crab_dwell_case_opinion"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b5_crab_dwell_background_reply` (beat5)

- route: id-token 'crab'
- trigger: `chapter1.state_choice == 'cula_b5_crab_dwell_background'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Crab. Before we start: what's the shape of your background?"
  ],
  "once": true
}
```

### [ ] `cula_b5_crab_dwell_why_here_reply` (beat5)

- route: id-token 'crab'
- trigger: `chapter1.state_choice == 'cula_b5_crab_dwell_why_here'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Why Pig & Swine? You could have gone somewhere with a working printer."
  ],
  "once": true
}
```

### [ ] `cula_b5_crab_dwell_case_opinion_reply` (beat5)

- route: id-token 'crab'
- trigger: `chapter1.state_choice == 'cula_b5_crab_dwell_case_opinion'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "You've seen the binder pages. Any opinion on the case before I waste your aftern"
  ],
  "once": true
}
```

### [ ] `cula_b13_crab_response` (beat13)

- route: id-token 'crab'
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "The address argument carried it, Crab. Most of the round was your reading."
  ]
}
```

## halina.json

### [ ] `cula_b8_halina_arrival_greeting` (beat8)

- route: id-token 'halina'
- trigger: `chapter1.halina_arrived == true && !chapter1.halina_met`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Good morning, Mrs. Sikorska. Dr. A. Cula.",
    "This is Murrow, who has handled the case from the file. And my colleagues, Crab "
  ]
}
```

### [ ] `cula_b8_approach_choice` (beat8)

- route: tag 'halina'
- trigger: `chapter1.halina_met == true && chapter1.client_meeting_stance == ''`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mrs. Sikorska. Before we open the folder, let me ask one question to set the sha"
  ],
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "Lead with how she is holding up. The eviction is on her, not",
        "value": "sympathetic"
      },
      {
        "text": "Lead with the notice. The sequence is what will land in cour",
        "value": "blunt_procedural"
      },
      {
        "text": "Lead with the lease and the inheritance. The tenancy validit",
        "value": "technical"
      }
    ]
  }
}
```
- note: LOAD_BEARING — verify ownership before moving
- note: carries LOAD_BEARING tag variant

### [ ] `cula_b8_sympathetic_open` (beat8)

- route: tag 'halina'
- trigger: `chapter1.client_meeting_stance == 'sympathetic' && !chapter1.halina_close_done`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mrs. Sikorska, before the documents. How are you managing this? You have had thr",
    "And the building. How long have you been there?"
  ]
}
```

### [ ] `cula_b8_sympathetic_internal_fee` (beat8)

- route: tag 'halina'
- trigger: `chapter1.client_meeting_stance == 'sympathetic' && chapter1.client_fee_agreed == true`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "Five thousand. That is most of her month."
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b8_blunt_procedural_open` (beat8)

- route: tag 'halina'
- trigger: `chapter1.client_meeting_stance == 'blunt_procedural' && !chapter1.halina_close_done`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mrs. Sikorska. If it is all right with you, I will go in order. The notice. When",
    "And before that one. Had there been other letters from the landlord, in the mont"
  ]
}
```

### [ ] `cula_b8_blunt_procedural_internal_fee` (beat8)

- route: tag 'halina'
- trigger: `chapter1.client_meeting_stance == 'blunt_procedural' && chapter1.client_fee_agreed == true`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "Fixed fee, no retainer, paid before court. Clean."
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b8_technical_open` (beat8)

- route: tag 'halina'
- trigger: `chapter1.client_meeting_stance == 'technical' && !chapter1.halina_close_done`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mrs. Sikorska. Could we begin with the paperwork itself. The original lease, the",
    "And the renumbering. Do you have anything from the building administration about"
  ]
}
```

### [ ] `cula_b8_technical_internal_fee` (beat8)

- route: tag 'halina'
- trigger: `chapter1.client_meeting_stance == 'technical' && chapter1.client_fee_agreed == true`
- speaker: `cula_internal`
- payload:
```json
{
  "lines": [
    "Single payment, no instalments, no retainer. That is the cleanest fee shape this"
  ]
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b8_dwell_apartment_reply` (beat8)

- route: tag 'halina'
- trigger: `chapter1.state_choice == 'cula_b8_dwell_apartment'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mrs. Sikorska. Tell me about the apartment. Not the case. The apartment itself."
  ],
  "once": true
}
```

### [ ] `cula_b8_dwell_referral_reply` (beat8)

- route: tag 'halina'
- trigger: `chapter1.state_choice == 'cula_b8_dwell_referral'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "And how did you come to find us? Was there anyone else you were speaking with?"
  ],
  "once": true
}
```

### [ ] `cula_b8_dwell_taught_reply` (beat8)

- route: tag 'halina'
- trigger: `chapter1.state_choice == 'cula_b8_dwell_taught'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "I take it from how you have laid out the folder that you have done a lot of care"
  ],
  "once": true
}
```

### [ ] `cula_b8_cardiologist_silent_reaction` (beat8)

- route: tag 'halina'
- trigger: `chapter1.cardiologist_plant_landed == true`
- speaker: `cula_internal`
- payload:
```json
{
  "silent": true
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b8_literary_epigram_reaction` (beat8)

- route: tag 'halina'
- trigger: `chapter1.halina_close_done == true`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "I will try to make the visit worth the timing, Mrs. Sikorska."
  ]
}
```

### [ ] `cula_b8_halina_closeout` (beat8)

- route: id-token 'halina'
- trigger: `chapter1.halina_close_done == true && chapter1.client_fee_agreed == true && !chapter1.archive_research_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Thank you. We will have the motion drafted by tomorrow afternoon; the firm will ",
    "Murrow. Archive Room?"
  ]
}
```

## judge_district_ch1.json

### [ ] `cula_b12_round1_response` (beat12)

- route: court beat tag
- trigger: `chapter1.entered_court == true && chapter1.casebook_judge_state != ''`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Your Honor. The notice was served to a non-current address. The building was ren",
    "The client should not be treated as silent where the process failed to give her "
  ]
}
```

### [ ] `cula_b12_round2_response` (beat12)

- route: court beat tag
- trigger: `chapter1.casebook_judge_state == 'round2_open' || chapter1.casebook_judge_state == 'round2_active'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Your Honor. A party cannot meaningfully defend a case it was never properly brou"
  ]
}
```

### [ ] `cula_b12_round3_remedy_sympathetic` (beat12)

- route: court beat tag
- trigger: `chapter1.casebook_judge_state == 'round3_open' && chapter1.client_meeting_stance == 'sympathetic'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Your Honor. The defect was a year in the making, but its effect on Mrs. Sikorska",
    "We do not ask the court to decide the whole dispute today. We ask that the heari"
  ]
}
```
- note: carries LOAD_BEARING tag variant

### [ ] `cula_b12_round3_remedy_blunt_procedural` (beat12)

- route: court beat tag
- trigger: `chapter1.casebook_judge_state == 'round3_open' && chapter1.client_meeting_stance == 'blunt_procedural'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Your Honor. The defects are sequential. Service was invalid under Article 135-bi",
    "On those grounds the hearing should be set aside and rescheduled."
  ]
}
```
- note: carries LOAD_BEARING tag variant

### [ ] `cula_b12_round3_remedy_technical` (beat12)

- route: court beat tag
- trigger: `chapter1.casebook_judge_state == 'round3_open' && chapter1.client_meeting_stance == 'technical'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Your Honor. The tenancy is documented from nineteen sixty-two, original lease in",
    "On those grounds the hearing should be set aside and rescheduled so that the sub"
  ]
}
```
- note: carries LOAD_BEARING tag variant

## murrow.json

### [ ] `cula_b4_murrow_first_meeting_greeting` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.has_law_binder == true && chapter1.pig_revealed_crisis == true && !chapter1.met_murrow`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mr. Murrow. I was told you'd have the Sikorska file.",
    "Mr. Pig is currently in maritime conditions. I gathered it would be easier to as"
  ]
}
```

### [ ] `cula_b4_murrow_briefing_acknowledgment` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.met_murrow == true && !chapter1.recruited_crab && chapter1.has_law_binder == true`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "So the problem is not that the client missed the deadline. It is whether the cli",
    "Wrong-door service, fourteen days from actual notice, motion to set aside. I can"
  ]
}
```

### [ ] `cula_b4_murrow_first_name_acceptance` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.met_murrow == true && !chapter1.recruited_crab`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Then it's Cula."
  ]
}
```

### [ ] `cula_b4_murrow_dwell_options` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.met_murrow == true && !chapter1.recruited_crab && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(tenure)",
        "value": "cula_b4_murrow_dwell_tenure"
      },
      {
        "text": "(pattern)",
        "value": "cula_b4_murrow_dwell_pattern"
      },
      {
        "text": "(client)",
        "value": "cula_b4_murrow_dwell_client"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b4_murrow_dwell_tenure_reply` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.state_choice == 'cula_b4_murrow_dwell_tenure'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Murrow. Out of curiosity. How long have you been at Pig & Swine?"
  ],
  "once": true
}
```

### [ ] `cula_b4_murrow_dwell_pattern_reply` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.state_choice == 'cula_b4_murrow_dwell_pattern'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Murrow. The wrong-address mechanism. Have you seen this shape of defect before?"
  ],
  "once": true
}
```

### [ ] `cula_b4_murrow_dwell_client_reply` (beat4)

- route: id-token 'murrow'
- trigger: `chapter1.state_choice == 'cula_b4_murrow_dwell_client'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "And before I meet her. What should I expect from Mrs. Sikorska?"
  ],
  "once": true
}
```

### [ ] `cula_b9_murrow_first_clause_response` (beat9)

- route: id-token 'murrow'
- trigger: `chapter1.archive_research_complete == false && chapter1.has_law_binder == true`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "So the knowledge requirement is met. The landlord authorised the renumbering; th",
    "Murrow. That is half the work done before we wrote anything."
  ]
}
```

### [ ] `cula_b9_murrow_second_clause_response` (beat9)

- route: id-token 'murrow'
- trigger: `chapter1.archive_research_complete == false && chapter1.has_law_binder == true`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Notice on the twenty-eighth of April; today's date; that puts us inside the wind",
    "Murrow. Do we file the motion before or after the hearing time on Friday?"
  ]
}
```

### [ ] `cula_b9_murrow_third_clause_response` (beat9)

- route: id-token 'murrow'
- trigger: `chapter1.archive_research_complete == false && chapter1.has_law_binder == true`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Good. Then 'they accepted the notice' fails on its face. The current renter at n"
  ]
}
```

### [ ] `cula_b9_dwell_how_found_reply` (beat9)

- route: tag 'murrow'
- trigger: `chapter1.state_choice == 'cula_b9_dwell_how_found'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Murrow. The binder has hundreds of pages. How did you find the article that fits"
  ],
  "once": true
}
```

### [ ] `cula_b9_dwell_used_before_reply` (beat9)

- route: tag 'murrow'
- trigger: `chapter1.state_choice == 'cula_b9_dwell_used_before'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Have you actually run a one-thirty-five-bis motion before, or is this our first?"
  ],
  "once": true
}
```

### [ ] `cula_b9_dwell_next_reply` (beat9)

- route: tag 'murrow'
- trigger: `chapter1.state_choice == 'cula_b9_dwell_next'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Murrow. What is on the checklist between now and Friday?"
  ],
  "once": true
}
```

### [ ] `cula_b10_readiness_check` (beat10)

- route: tag 'murrow'
- trigger: `chapter1.archive_research_complete == true && !chapter1.court_ready`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Murrow. We have service, fairness, and a modest remedy. Please tell me that is a",
    "Walk route, court time, who carries what. Run me through the checklist."
  ]
}
```

### [ ] `cula_b13_murrow_ledger_silent` (beat13)

- route: id-token 'murrow'
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula_internal`
- payload:
```json
{
  "silent": true
}
```
- note: cula_internal speaker — render as internal echo, not dialogue line

### [ ] `cula_b13_brief_murrow_response` (beat13)

- route: tag 'murrow'
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Murrow. Send me what you have on the next file. Tomorrow morning is fine."
  ]
}
```

## pig.json

### [ ] `cula_b3_pig_first_encounter` (beat3)

- route: id-token 'pig'
- trigger: `chapter1.met_asia == true && !chapter1.met_pig`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mr. Pig. Cula. The reception sent me back.",
    "I gather there is a great deal happening this morning.",
    "Would you like to start with the firm, the client, or the deadline?"
  ]
}
```

### [ ] `cula_b3_pig_rent_reaction` (beat3)

- route: id-token 'pig'
- trigger: `chapter1.met_pig == true && !chapter1.pig_revealed_crisis`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Six weeks. Understood.",
    "I will take that as a fact and find Mr. Murrow."
  ]
}
```

### [ ] `cula_b3_pig_dwell_options` (beat3)

- route: id-token 'pig'
- trigger: `chapter1.pig_revealed_crisis == true && !chapter1.met_murrow && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(case)",
        "value": "cula_b3_pig_dwell_case"
      },
      {
        "text": "(okay)",
        "value": "cula_b3_pig_dwell_okay"
      },
      {
        "text": "(swine)",
        "value": "cula_b3_pig_dwell_swine"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b3_pig_dwell_case_reply` (beat3)

- route: id-token 'pig'
- trigger: `chapter1.state_choice == 'cula_b3_pig_dwell_case'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mr. Pig. The case itself. Could you give me the shape of it?"
  ],
  "once": true
}
```

### [ ] `cula_b3_pig_dwell_okay_reply` (beat3)

- route: id-token 'pig'
- trigger: `chapter1.state_choice == 'cula_b3_pig_dwell_okay'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Before I go, Mr. Pig. Are you all right? Today aside."
  ],
  "once": true
}
```

### [ ] `cula_b3_pig_dwell_swine_reply` (beat3)

- route: id-token 'pig'
- trigger: `chapter1.state_choice == 'cula_b3_pig_dwell_swine'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "And Mr. Swine. Is he expected back this week, or is he travelling?"
  ],
  "once": true
}
```

### [ ] `cula_b10_pig_lecture_reception` (beat10)

- route: id-token 'pig'
- trigger: `chapter1.pig_revealed_crisis == true && !chapter1.court_ready`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Understood, Mr. Pig. We will keep the printer informed."
  ]
}
```

### [x] `cula_b13_pig_celebration_response` (beat13)

- route: id-token 'pig'
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Temporarily saved is still saved, Mr. Pig. I am learning that this office measur"
  ]
}
```
- already_present: source id 'cula_b13_pig_celebration_response' referenced in target _comment

## postcard_swine_ch1.json

### [x] `cula_b14_postcard_reaction` (beat14)

- route: postcard tag
- trigger: `chapter1.received_swine_postcard == true && !chapter1.complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Japan, ski resorts, arbitration, no immediate downside. I distrust every noun in"
  ]
}
```
- already_present: source id 'cula_b14_postcard_reaction' referenced in target _comment

### [ ] `cula_b14_chapter_close` (beat14)

- route: postcard tag
- trigger: `chapter1.received_swine_postcard == true && !chapter1.complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Three districts on the map I could not walk through this morning. That is a lot ",
    "Tomorrow. Murrow's next file, then the doors."
  ]
}
```

## whimsy.json

### [ ] `cula_b7_whimsy_first_meeting` (beat7)

- route: id-token 'whimsy'
- trigger: `chapter1.recruited_crab == true && !chapter1.met_whimsy`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mr. Whimsy. Cula, Pig & Swine.",
    "There is a rights memo with coffee damage on it, and a hearing on Friday. I am t"
  ]
}
```

### [x] `cula_b7_whimsy_procedural_vibes_response` (beat7)

- route: id-token 'whimsy'
- trigger: `chapter1.met_whimsy == true && !chapter1.recruited_whimsy`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Vibes won't carry it. The defect is service; the doorway is fair hearing; the ar"
  ]
}
```
- already_present: trigger overlap with target state 'whimsy_coffee_reaction_perfect_pre_recruit'

### [ ] `cula_b7_whimsy_dwell_options` (beat7)

- route: id-token 'whimsy'
- trigger: `chapter1.met_whimsy == true && !chapter1.recruited_whimsy && chapter1.state_choice == ''`
- speaker: `cula`
- payload:
```json
{
  "options": {
    "write_path": "chapter1.state_choice",
    "chain": true,
    "choices": [
      {
        "text": "(office)",
        "value": "cula_b7_whimsy_dwell_office"
      },
      {
        "text": "(case read)",
        "value": "cula_b7_whimsy_dwell_case_read"
      },
      {
        "text": "(office visits)",
        "value": "cula_b7_whimsy_dwell_office_visits"
      }
    ]
  }
}
```
- note: source _comment already flags fan-out need

### [ ] `cula_b7_whimsy_dwell_office_reply` (beat7)

- route: id-token 'whimsy'
- trigger: `chapter1.state_choice == 'cula_b7_whimsy_dwell_office'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Mr. Whimsy. Why the café, and not the office?"
  ],
  "once": true
}
```

### [ ] `cula_b7_whimsy_dwell_case_read_reply` (beat7)

- route: id-token 'whimsy'
- trigger: `chapter1.state_choice == 'cula_b7_whimsy_dwell_case_read'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Setting the law aside for a second: what is your read on this one?"
  ],
  "once": true
}
```

### [ ] `cula_b7_whimsy_dwell_office_visits_reply` (beat7)

- route: id-token 'whimsy'
- trigger: `chapter1.state_choice == 'cula_b7_whimsy_dwell_office_visits'`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "Honest question: do you ever turn up at the office, or is this the rest of the l"
  ],
  "once": true
}
```

### [ ] `cula_b13_whimsy_response` (beat13)

- route: id-token 'whimsy'
- trigger: `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`
- speaker: `cula`
- payload:
```json
{
  "lines": [
    "I will look forward to the score, Whimsy. The written closing first, if you can."
  ]
}
```

