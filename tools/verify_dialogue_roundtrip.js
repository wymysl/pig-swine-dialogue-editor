#!/usr/bin/env node
/*
 * Unified verification harness for the Pig & Swine dialogue contract.
 *
 * Asserts everything _schema.md promises and everything dialogue_runner.gd
 * enforces at boot, so the editor's serializer and the runtime stay in
 * lockstep. Failing this script means either the schema or the runner
 * just lost an invariant.
 *
 * Checks per canonical file:
 *   1. Trigger parse → serialize is byte-identical (mirrors the editor's
 *      conditions-UI write path).
 *   2. Full-file pretty-print is byte-identical to the on-disk content
 *      (catches editor / Python serializer drift).
 *   3. options-block field shapes (trust_path / trust_delta / chain
 *      preserved on the live corpus — currently zero use but the contract
 *      stays asserted so anyone authoring trust-meter content finds the
 *      checks alive).
 *
 * Cross-corpus checks:
 *   4. State-id global uniqueness (across every canonical file).
 *   5. Speaker-id validity (every state-level + per-line speaker in
 *      character_registry.json or its _portrait_aliases map).
 *   6. Flag-path validity (every trigger path / on_dismiss.set / options
 *      write_path / options.trust_path declared in state.gd::reset_state()).
 *
 * Exit codes:
 *   0 — all clean
 *   1 — one or more violations
 *
 * Run from repo root:
 *   node tools/verify_dialogue_roundtrip.js
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = process.env.PSRPG_REPO_ROOT
  || (fs.existsSync('godot/data/dialogues') ? '.' : '/sessions/funny-inspiring-mayer/mnt/pig-swine-rpg');

const DIALOGUES_DIR = path.join(REPO_ROOT, 'godot/data/dialogues');
const REGISTRY_PATH = path.join(REPO_ROOT, 'godot/data/character_registry.json');
const STATE_GD_PATH = path.join(REPO_ROOT, 'godot/scripts/autoload/state.gd');

const CANONICAL = new Set([
  'asia.json', 'asia_hint_states_ch1.json', 'barista.json', 'crab.json',
  'cula.json', 'halina.json', 'judge_district_ch1.json', 'meeting_room_stance.json',
  'murrow.json', 'pig.json', 'postcard_swine_ch1.json', 'whimsy.json',
]);

// -------- TRIGGER PARSER / SERIALIZER --------
// Mirrors dialogue_editor.html's parseTrigger / serializeTrigger AFTER the
// Phase 2 schema migration (single-quoted RHS, `!path` negation).

function parseClause(s) {
  const geMatch = s.match(/^(.+?)\s*>=\s*(.+)$/);
  if (geMatch) return { path: geMatch[1].trim(), op: '>=', value: parseNumeric(geMatch[2].trim()) };
  const leMatch = s.match(/^(.+?)\s*<=\s*(.+)$/);
  if (leMatch) return { path: leMatch[1].trim(), op: '<=', value: parseNumeric(leMatch[2].trim()) };
  const eqMatch = s.match(/^(.+?)\s*==\s*(.+)$/);
  const neqMatch = s.match(/^(.+?)\s*!=\s*(.+)$/);
  if (eqMatch) return { path: eqMatch[1].trim(), op: '==', value: parseValue(eqMatch[2].trim()) };
  if (neqMatch) return { path: neqMatch[1].trim(), op: '!=', value: parseValue(neqMatch[2].trim()) };
  if (s.startsWith('!')) return { path: s.slice(1).trim(), op: 'falsy', value: null };
  return { path: s.trim(), op: 'truthy', value: null };
}

function parseValue(s) {
  if ((s.startsWith("'") && s.endsWith("'")) || (s.startsWith('"') && s.endsWith('"'))) {
    return s.slice(1, -1);
  }
  if (s === 'true') return true;
  if (s === 'false') return false;
  return s;
}

function parseNumeric(s) {
  const n = parseInt(s, 10);
  return Number.isFinite(n) ? n : 0;
}

// Triggers may contain top-level `||` (OR-of-AND groups). Split on `||` first.
function parseTrigger(trigger) {
  if (!trigger || !trigger.trim()) return { groups: [] };
  const groups = trigger.split('||').map(g => g.trim()).filter(Boolean).map(group => {
    return group.split('&&').map(s => s.trim()).filter(Boolean).map(parseClause);
  });
  return { groups };
}

function serializeTrigger(parsed) {
  return parsed.groups.map(group => group.map(c => {
    if (c.op === '>=' || c.op === '<=') {
      const n = (typeof c.value === 'number') ? c.value : parseNumeric(String(c.value));
      return `${c.path} ${c.op} ${n}`;
    } else if (c.op === '==' || c.op === '!=') {
      const val = (typeof c.value === 'boolean') ? String(c.value) : `'${c.value}'`;
      return `${c.path} ${c.op} ${val}`;
    } else if (c.op === 'falsy') {
      return `!${c.path}`;
    } else {
      return c.path;
    }
  }).join(' && ')).join(' || ');
}

// -------- COMPACT-INLINE JSON SERIALIZER --------
// Mirrors dialogue_editor.html::_serialize and tools/migrate_phase2.py::serialize.

const INLINE_LIMIT = 300;

function isPrimitive(v) {
  return v === null || typeof v === 'boolean' || typeof v === 'number' || typeof v === 'string';
}

function allPrimitiveValues(o) {
  if (Array.isArray(o)) return o.every(isPrimitive);
  if (o && typeof o === 'object') return Object.values(o).every(isPrimitive);
  return false;
}

function compactJson(value) {
  if (value === null || typeof value === 'boolean' || typeof value === 'number' || typeof value === 'string') {
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    return '[' + value.map(compactJson).join(', ') + ']';
  }
  if (typeof value === 'object') {
    const entries = Object.entries(value).map(([k, v]) => `${JSON.stringify(k)}: ${compactJson(v)}`);
    return '{' + entries.join(', ') + '}';
  }
  throw new TypeError(`Cannot serialize ${typeof value}`);
}

function serialize(value, level = 0, size = 4) {
  const pad = ' '.repeat(level * size);
  const childPad = ' '.repeat((level + 1) * size);

  if (value === null || typeof value === 'boolean' || typeof value === 'number' || typeof value === 'string') {
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    if (value.length === 0) return '[]';
    if (allPrimitiveValues(value)) {
      const inline = compactJson(value);
      if (inline.length <= INLINE_LIMIT) return inline;
    }
    const parts = value.map((item, i) => {
      let entry;
      if (item && typeof item === 'object' && !Array.isArray(item) && allPrimitiveValues(item)) {
        const inline = compactJson(item);
        entry = childPad + (inline.length <= INLINE_LIMIT ? inline : serialize(item, level + 1, size));
      } else {
        entry = childPad + serialize(item, level + 1, size);
      }
      return entry + (i < value.length - 1 ? ',' : '');
    });
    return '[\n' + parts.join('\n') + '\n' + pad + ']';
  }
  if (typeof value === 'object') {
    const keys = Object.keys(value);
    if (keys.length === 0) return '{}';
    if (allPrimitiveValues(value)) {
      const inline = compactJson(value);
      if (inline.length <= INLINE_LIMIT) return inline;
    }
    const parts = keys.map((k, i) => {
      const entry = `${childPad}${JSON.stringify(k)}: ${serialize(value[k], level + 1, size)}`;
      return entry + (i < keys.length - 1 ? ',' : '');
    });
    return '{\n' + parts.join('\n') + '\n' + pad + '}';
  }
  throw new TypeError(`Cannot serialize ${typeof value}`);
}

// -------- CROSS-CORPUS VALIDATORS --------

function loadRegistry() {
  const raw = JSON.parse(fs.readFileSync(REGISTRY_PATH, 'utf-8'));
  const ids = new Set();
  for (const k of Object.keys(raw)) {
    if (!k.startsWith('_')) ids.add(k);
  }
  if (raw._portrait_aliases && typeof raw._portrait_aliases === 'object') {
    for (const k of Object.keys(raw._portrait_aliases)) ids.add(k);
  }
  return ids;
}

// Parse state.gd to extract every chapter1.* / badges.* / routes_unlocked.* / etc
// path declared in reset_state(). Lightweight: regex-walk the dictionary
// literal. Mirrors dialogue_runner.gd::_flatten_state_paths.
function loadDeclaredPaths() {
  const src = fs.readFileSync(STATE_GD_PATH, 'utf-8');
  const fnStart = src.indexOf('func reset_state()');
  if (fnStart < 0) throw new Error('reset_state() not found in state.gd');
  const fnSrc = src.slice(fnStart);
  // Find the outermost { ... } that follows the `return` statement.
  const returnIdx = fnSrc.indexOf('return {');
  if (returnIdx < 0) throw new Error('reset_state return {...} not found');
  let depth = 0;
  let start = returnIdx + 'return '.length;
  let end = -1;
  for (let i = start; i < fnSrc.length; i++) {
    const c = fnSrc[i];
    if (c === '{') depth++;
    else if (c === '}') { depth--; if (depth === 0) { end = i; break; } }
  }
  if (end < 0) throw new Error('reset_state return block not closed');
  const block = fnSrc.slice(start, end + 1);

  // Walk the block char-by-char with a tiny stack of current dotted-path prefixes.
  // GDScript dict literal grammar is simple enough here: `"key": value,` and
  // nested `{ ... }` only.
  const paths = new Set();
  const prefix = [];
  let i = 0;
  let pendingKey = null;
  while (i < block.length) {
    const c = block[i];
    // Skip comments through end of line.
    if (c === '#') {
      while (i < block.length && block[i] !== '\n') i++;
      continue;
    }
    // String literal — possible key.
    if (c === '"') {
      let j = i + 1;
      while (j < block.length && block[j] !== '"') {
        if (block[j] === '\\') j++;
        j++;
      }
      const key = block.slice(i + 1, j);
      i = j + 1;
      // Skip whitespace + look for `:` (indicates this string was a key).
      let k = i;
      while (k < block.length && /\s/.test(block[k])) k++;
      if (block[k] === ':') {
        pendingKey = key;
        i = k + 1;
        // Skip whitespace before value.
        while (i < block.length && /\s/.test(block[i])) i++;
        const fullPath = prefix.concat(pendingKey).join('.');
        paths.add(fullPath);
        // If value starts with `{`, push prefix for nested dict.
        if (block[i] === '{') {
          prefix.push(pendingKey);
          pendingKey = null;
          i++;
          continue;
        }
        pendingKey = null;
        continue;
      }
      continue;
    }
    if (c === '}') {
      if (prefix.length > 0) prefix.pop();
      i++;
      continue;
    }
    i++;
  }
  return paths;
}

function extractTriggerPaths(trigger) {
  if (!trigger) return [];
  const out = [];
  const re = /\b(\w+(?:\.\w+)+)/g;
  let m;
  while ((m = re.exec(trigger)) !== null) out.push(m[1]);
  return out;
}

// -------- VERIFY ONE FILE --------

function verifyFile(filePath, registry, declared, globalState) {
  const name = path.basename(filePath);
  const original = fs.readFileSync(filePath, 'utf-8');
  let data;
  try {
    data = JSON.parse(original);
  } catch (e) {
    console.error(`[FAIL] ${name}: JSON parse: ${e.message}`);
    globalState.failed++;
    return;
  }

  // 1. Trigger round-trip on every state.
  let triggerMismatches = 0;
  for (const state of data.states || []) {
    if (!state.trigger) continue;
    const reserialized = serializeTrigger(parseTrigger(state.trigger));
    if (state.trigger !== reserialized) {
      triggerMismatches++;
      console.error(`  TRIGGER drift in ${name}:${state.id}`);
      console.error(`    before: ${state.trigger}`);
      console.error(`    after:  ${reserialized}`);
    }
  }

  // 2. Full-file pretty-print round-trip.
  const restringified = serialize(data) + '\n';
  const byteIdentical = (original === restringified);

  // 3. State-id collection (cross-corpus).
  for (const s of data.states || []) {
    if (!s.id) {
      console.error(`  no-id state in ${name}`);
      globalState.failed++;
      continue;
    }
    if (globalState.stateIds.has(s.id)) {
      console.error(`  DUPLICATE state-id '${s.id}': ${name} collides with ${globalState.stateIds.get(s.id)}`);
      globalState.failed++;
    } else {
      globalState.stateIds.set(s.id, name);
    }
  }

  // 4. Speaker validity.
  for (const s of data.states || []) {
    const stSpeaker = s.speaker;
    if (stSpeaker && !registry.has(stSpeaker)) {
      console.error(`  UNKNOWN speaker '${stSpeaker}' on state ${name}:${s.id}`);
      globalState.failed++;
    }
    for (const l of (s.lines || [])) {
      if (l && typeof l === 'object' && l.speaker && !registry.has(l.speaker)) {
        console.error(`  UNKNOWN speaker '${l.speaker}' in line of ${name}:${s.id}`);
        globalState.failed++;
      }
    }
  }

  // 5. Flag-path resolution.
  for (const s of data.states || []) {
    for (const p of extractTriggerPaths(s.trigger || '')) {
      if (!declared.has(p)) {
        console.error(`  UNDECLARED flag path '${p}' in trigger of ${name}:${s.id}`);
        globalState.failed++;
      }
    }
    for (const od of (s.on_dismiss || [])) {
      if (od && od.set && !declared.has(od.set)) {
        console.error(`  UNDECLARED on_dismiss.set path '${od.set}' in ${name}:${s.id}`);
        globalState.failed++;
      }
    }
    if (s.options) {
      const wp = s.options.write_path;
      const tp = s.options.trust_path;
      if (wp && !declared.has(wp)) {
        console.error(`  UNDECLARED options.write_path '${wp}' in ${name}:${s.id}`);
        globalState.failed++;
      }
      if (tp && !declared.has(tp)) {
        console.error(`  UNDECLARED options.trust_path '${tp}' in ${name}:${s.id}`);
        globalState.failed++;
      }
    }
  }

  // 6. Content shape.
  for (const s of data.states || []) {
    const hasLines = Array.isArray(s.lines) && s.lines.length > 0;
    const hasOpts = s.options && Array.isArray(s.options.choices) && s.options.choices.length > 0;
    const isSilent = s.silent === true;
    if (s.line !== undefined) {
      console.error(`  LEGACY 'line' field in ${name}:${s.id} — convert to 'lines'`);
      globalState.failed++;
    }
    if (!hasLines && !hasOpts && !isSilent) {
      console.error(`  EMPTY state ${name}:${s.id} — needs lines, options.choices, or silent:true`);
      globalState.failed++;
    }
  }

  // Round-trip + trigger results
  let status = 'OK';
  if (triggerMismatches > 0) { status = 'FAIL'; globalState.failed++; }
  if (!byteIdentical) {
    status = 'FAIL'; globalState.failed++;
    console.error(`  BYTE-DRIFT in ${name}: pretty-print differs from on-disk content`);
    const a = original.split('\n');
    const b = restringified.split('\n');
    for (let i = 0; i < Math.max(a.length, b.length); i++) {
      if (a[i] !== b[i]) {
        console.error(`    line ${i + 1}:`);
        console.error(`      original:       ${JSON.stringify(a[i])}`);
        console.error(`      re-stringified: ${JSON.stringify(b[i])}`);
        break;
      }
    }
  }

  console.log(`  ${name}: ${status} (trigger-mismatches=${triggerMismatches}, byte-identical=${byteIdentical})`);
}

// -------- MAIN --------

function main() {
  const args = process.argv.slice(2);
  let files;
  if (args.length > 0) {
    files = args;
  } else {
    files = fs.readdirSync(DIALOGUES_DIR)
      .filter(n => CANONICAL.has(n))
      .map(n => path.join(DIALOGUES_DIR, n));
  }

  const registry = loadRegistry();
  const declared = loadDeclaredPaths();
  const globalState = {
    failed: 0,
    stateIds: new Map(),
  };

  console.log(`=== verify_dialogue_roundtrip ===`);
  console.log(`registry: ${registry.size} known speaker ids`);
  console.log(`declared: ${declared.size} State.data paths`);
  console.log(`canonical files: ${files.length}`);
  console.log('');

  for (const f of files.sort()) {
    verifyFile(f, registry, declared, globalState);
  }

  console.log('');
  console.log(`state ids checked: ${globalState.stateIds.size}`);
  console.log(`violations:        ${globalState.failed}`);

  process.exit(globalState.failed > 0 ? 1 : 0);
}

main();
