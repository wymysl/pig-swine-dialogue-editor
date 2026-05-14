// Standalone re-implementation of the dialogue_editor.html parser/serializer
// just enough to verify byte-equivalent round-trip on the trigger field.
// Mirrors the JS in tools/dialogue_editor.html after the >= / <= edits.

const fs = require('fs');
const path = require('path');

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

function parseTrigger(trigger) {
  if (!trigger || !trigger.trim()) return [];
  return trigger.split('&&').map(s => s.trim()).filter(s => s).map(parseClause);
}

function serializeTrigger(clauses) {
  return clauses.map(c => {
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
  }).join(' && ');
}

const halinaPath = process.argv[2] || '/sessions/gracious-fervent-noether/mnt/pig-swine-rpg/godot/data/dialogues/halina.json';
const data = JSON.parse(fs.readFileSync(halinaPath, 'utf-8'));

let total = 0;
let mismatches = 0;
let preserved_ge_le = 0;
let preserved_trust_delta = 0;
let preserved_trust_path = 0;
let preserved_chain = 0;

console.log('--- Trigger round-trip ---');
for (const state of data.states || []) {
  if (!state.trigger) continue;
  total++;
  const parsed = parseTrigger(state.trigger);
  const reserialized = serializeTrigger(parsed);
  if (state.trigger !== reserialized) {
    mismatches++;
    console.log(`MISMATCH in state ${state.id}:`);
    console.log(`  before: ${state.trigger}`);
    console.log(`  after:  ${reserialized}`);
    console.log(`  parsed: ${JSON.stringify(parsed)}`);
  }
  if (state.trigger.includes('>=') || state.trigger.includes('<=')) {
    preserved_ge_le++;
  }
}

console.log(`\nTriggers parsed: ${total}`);
console.log(`Mismatches:      ${mismatches}`);
console.log(`>= / <= clauses present: ${preserved_ge_le}`);

console.log('\n--- Options-block fields ---');
for (const state of data.states || []) {
  const opts = state.options;
  if (!opts) continue;
  if (opts.trust_path) preserved_trust_path++;
  if (opts.chain === true) preserved_chain++;
  if (Array.isArray(opts.choices)) {
    for (const c of opts.choices) {
      if (typeof c.trust_delta === 'number') preserved_trust_delta++;
    }
  }
}

console.log(`trust_path occurrences:  ${preserved_trust_path}`);
console.log(`chain:true occurrences:  ${preserved_chain}`);
console.log(`trust_delta occurrences: ${preserved_trust_delta}`);

// Simulate full-file JSON round-trip: load → stringify (4-space, trailing newline as editor does) → diff.
const original = fs.readFileSync(halinaPath, 'utf-8');
const restringified = JSON.stringify(data, null, 4) + '\n';

console.log('\n--- Full-file JSON round-trip ---');
if (original === restringified) {
  console.log('byte-identical: YES');
} else {
  console.log('byte-identical: NO');
  // Show the first diff line for diagnostics.
  const a = original.split('\n');
  const b = restringified.split('\n');
  const max = Math.max(a.length, b.length);
  for (let i = 0; i < max; i++) {
    if (a[i] !== b[i]) {
      console.log(`  first diff at line ${i + 1}:`);
      console.log(`    original:     ${JSON.stringify(a[i])}`);
      console.log(`    re-stringified: ${JSON.stringify(b[i])}`);
      break;
    }
  }
}

process.exit(mismatches === 0 ? 0 : 1);
