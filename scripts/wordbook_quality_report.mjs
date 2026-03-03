import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const WORDBOOK_DIR = path.join(ROOT, 'app', 'src', 'main', 'assets', 'wordbooks');
const REPORT_PATH = path.join(ROOT, 'data', 'sources', 'WORDLIST_QUALITY_REPORT.md');
const BOOKS = ['cet4', 'cet6', 'ielts', 'toefl'];

function normalizeWord(raw) {
  return String(raw || '')
    .replace(/’/g, "'")
    .toLowerCase()
    .replace(/'/g, '')
    .replace(/[^a-z]/g, '')
    .trim();
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function analyzeBook(name, rows) {
  const seen = new Set();
  const duplicateWords = [];
  const invalidRows = [];
  const shortDefs = [];
  const suspiciousPos = [];
  const nonAlphaWords = [];
  const posFreq = new Map();

  for (let i = 0; i < rows.length; i += 1) {
    const row = rows[i];
    const word = String(row?.word || '').trim();
    const pos = String(row?.pos || '').trim();
    const def = String(row?.def || '').trim();
    const norm = normalizeWord(word);

    if (!word || !pos || !def || !norm) {
      invalidRows.push({ index: i, word, pos, def });
      continue;
    }

    if (seen.has(norm)) {
      duplicateWords.push(norm);
    }
    seen.add(norm);

    if (!/^[a-z]+$/.test(norm)) {
      nonAlphaWords.push(word);
    }
    if (def.length < 2) {
      shortDefs.push(word);
    }
    if (pos.length > 12 || !/[a-z]/i.test(pos)) {
      suspiciousPos.push({ word, pos });
    }

    posFreq.set(pos, (posFreq.get(pos) || 0) + 1);
  }

  const topPos = [...posFreq.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 8);

  return {
    name,
    total: rows.length,
    uniqueNormalized: seen.size,
    duplicateCount: duplicateWords.length,
    invalidCount: invalidRows.length,
    shortDefCount: shortDefs.length,
    suspiciousPosCount: suspiciousPos.length,
    nonAlphaWordCount: nonAlphaWords.length,
    samples: {
      duplicates: duplicateWords.slice(0, 10),
      invalidRows: invalidRows.slice(0, 5),
      shortDefs: shortDefs.slice(0, 10),
      suspiciousPos: suspiciousPos.slice(0, 10),
      nonAlphaWords: nonAlphaWords.slice(0, 10),
      topPos
    }
  };
}

function renderReport(results) {
  const date = new Date().toISOString();
  const lines = [];
  lines.push(`# Wordbook Quality Report`);
  lines.push('');
  lines.push(`Generated at: ${date}`);
  lines.push('');

  for (const item of results) {
    lines.push(`## ${item.name.toUpperCase()}`);
    lines.push('');
    lines.push(`- total: ${item.total}`);
    lines.push(`- uniqueNormalized: ${item.uniqueNormalized}`);
    lines.push(`- duplicateCount: ${item.duplicateCount}`);
    lines.push(`- invalidCount: ${item.invalidCount}`);
    lines.push(`- shortDefCount: ${item.shortDefCount}`);
    lines.push(`- suspiciousPosCount: ${item.suspiciousPosCount}`);
    lines.push(`- nonAlphaWordCount: ${item.nonAlphaWordCount}`);
    lines.push('');

    lines.push(`topPos:`);
    for (const [pos, count] of item.samples.topPos) {
      lines.push(`- ${pos}: ${count}`);
    }
    lines.push('');

    if (item.samples.duplicates.length > 0) {
      lines.push(`duplicateSamples: ${item.samples.duplicates.join(', ')}`);
      lines.push('');
    }
    if (item.samples.shortDefs.length > 0) {
      lines.push(`shortDefSamples: ${item.samples.shortDefs.join(', ')}`);
      lines.push('');
    }
    if (item.samples.suspiciousPos.length > 0) {
      lines.push(
        `suspiciousPosSamples: ${item.samples.suspiciousPos
          .map((x) => `${x.word}(${x.pos})`)
          .join(', ')}`
      );
      lines.push('');
    }
  }

  return `${lines.join('\n')}\n`;
}

function main() {
  const results = [];
  for (const name of BOOKS) {
    const file = path.join(WORDBOOK_DIR, `${name}.json`);
    const rows = readJson(file);
    results.push(analyzeBook(name, rows));
  }

  fs.writeFileSync(REPORT_PATH, renderReport(results), 'utf8');
  console.log(`Wrote ${path.relative(ROOT, REPORT_PATH)}`);
}

main();
