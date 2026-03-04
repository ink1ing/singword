import fs from 'node:fs';
import vm from 'node:vm';

const ROOT = process.cwd();
const SOURCES_DIR = `${ROOT}/data/sources`;
const ASSETS_DIR = `${ROOT}/android/app/src/main/assets/wordbooks`;

function normalizeWord(raw) {
  return String(raw || '')
    .replace(/’/g, "'")
    .toLowerCase()
    .replace(/'/g, '')
    .replace(/[^a-z]/g, '')
    .trim();
}

function safePos(rawPos) {
  const pos = String(rawPos || '').trim();
  if (!pos || pos === '-' || pos === '--') return 'n.';
  return pos.length > 12 ? 'n.' : pos;
}

function safeDef(rawDef, fallback) {
  const def = String(rawDef || '').trim();
  if (!def || def === '-' || def === '--') return fallback;
  return def;
}

function readText(path) {
  return fs.readFileSync(path, 'utf8');
}

function runJsAndGetVar(path, variableName) {
  const code = readText(path);
  const context = {};
  vm.createContext(context);
  vm.runInContext(`${code}\n;globalThis.__out = ${variableName};`, context, { timeout: 20_000 });
  return context.__out;
}

function addEntry(map, stats, sourceKey, rawWord, rawPos, rawDef, fallbackDef) {
  const normalized = normalizeWord(rawWord);
  if (normalized.length <= 1) {
    stats[sourceKey].skipped += 1;
    return;
  }
  if (map.has(normalized)) {
    stats[sourceKey].duplicates += 1;
    return;
  }
  map.set(normalized, {
    word: normalized,
    pos: safePos(rawPos),
    def: safeDef(rawDef, fallbackDef)
  });
  stats[sourceKey].added += 1;
}

function parseIeltsFromHefengxian(targetMap, stats) {
  const sourceKey = 'hefengxian_ielts';
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const vocab = runJsAndGetVar(`${SOURCES_DIR}/ielts_vocabulary.js`, 'vocabulary');
  for (const topic of Object.values(vocab || {})) {
    for (const group of topic.words || []) {
      for (const item of group) {
        addEntry(
          targetMap,
          stats,
          sourceKey,
          item.word,
          item.pos,
          item.meaning,
          'IELTS vocabulary'
        );
      }
    }
  }
}

function parseIeltsFromLearningZone(targetMap, stats) {
  const sourceKey = 'learningzone_ielts';
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const markdown = readText(`${SOURCES_DIR}/learningzone_vocabulary.md`);
  const wordRegex = /^\*\s+\*\*([^*]+)\*\*/gm;
  let match;
  while ((match = wordRegex.exec(markdown)) !== null) {
    addEntry(
      targetMap,
      stats,
      sourceKey,
      match[1],
      'n.',
      'IELTS vocabulary supplement',
      'IELTS vocabulary supplement'
    );
  }
}

function parseCet4FromCsv(targetMap, stats) {
  const sourceKey = 'ze3kr_cet4_csv';
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const lines = readText(`${SOURCES_DIR}/ze3kr_cet4.csv`)
    .replace(/^\uFEFF/, '')
    .split(/\r?\n/);

  for (const line of lines) {
    if (!line.includes(',')) {
      stats[sourceKey].skipped += 1;
      continue;
    }

    const idx = line.indexOf(',');
    const rawWord = line.slice(0, idx).replace(/^"|"$/g, '').trim();
    const payload = line
      .slice(idx + 1)
      .trim()
      .replace(/^"|"$/g, '')
      .replace(/""/g, '"');

    const normalized = normalizeWord(rawWord);
    if (normalized.length <= 1) {
      stats[sourceKey].skipped += 1;
      continue;
    }
    if (targetMap.has(normalized)) {
      stats[sourceKey].duplicates += 1;
      continue;
    }

    const posMatch = payload.match(/^([a-z]{1,4}\.)+/i);
    const pos = safePos((posMatch?.[0] || 'n.').toLowerCase());
    const def = safeDef(
      (posMatch ? payload.slice(posMatch[0].length) : payload).replace(/[;,，；]+/g, '；'),
      'CET-4 vocabulary'
    );

    targetMap.set(normalized, {
      word: normalized,
      pos,
      def
    });
    stats[sourceKey].added += 1;
  }
}

function parseCet6FromEditedTxt(targetMap, stats) {
  const sourceKey = 'mahavivo_cet6_txt';
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const lines = readText(`${SOURCES_DIR}/cet6_edited.txt`).split(/\r?\n/);

  for (const line of lines) {
    const row = String(line || '').trim();
    if (!row) {
      continue;
    }

    const firstSpace = row.indexOf(' ');
    if (firstSpace <= 0) {
      stats[sourceKey].skipped += 1;
      continue;
    }

    const rawWord = row.slice(0, firstSpace).trim();
    const normalized = normalizeWord(rawWord);
    if (normalized.length <= 1) {
      stats[sourceKey].skipped += 1;
      continue;
    }
    if (targetMap.has(normalized)) {
      stats[sourceKey].duplicates += 1;
      continue;
    }

    const rest = row.slice(firstSpace + 1).replace(/\[[^\]]*]/g, '').trim();
    const posMatch = rest.match(/^([a-z]{1,4}\.)/i);
    const pos = safePos((posMatch?.[1] || 'n.').toLowerCase());
    const def = safeDef(
      (posMatch ? rest.slice(posMatch[0].length) : rest).trim(),
      'CET-6 vocabulary'
    );

    targetMap.set(normalized, {
      word: normalized,
      pos,
      def
    });
    stats[sourceKey].added += 1;
  }
}

function extractToeflQuestionWord(questionRaw) {
  let word = String(questionRaw || '').trim();
  if (!word) return '';
  word = word.split(':')[0].trim();
  word = word.replace(/\[[^\]]*\]/g, ' ');
  word = word.replace(/\s+/g, ' ').trim();
  return word;
}

function parseToeflFromQuestionJs(targetMap, stats, fileName, sourceKey) {
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const questions = runJsAndGetVar(`${SOURCES_DIR}/${fileName}`, 'questions') || [];
  for (const q of questions) {
    const rawWord = extractToeflQuestionWord(q.question);
    if (!rawWord || rawWord.includes(' ')) {
      stats[sourceKey].skipped += 1;
      continue;
    }
    addEntry(
      targetMap,
      stats,
      sourceKey,
      rawWord,
      'n.',
      q.answer,
      'TOEFL vocabulary'
    );
  }
}

function parseToeflFromLadrift(targetMap, stats) {
  const sourceKey = 'ladrift_toefl';
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const lines = readText(`${SOURCES_DIR}/ladrift_toefl_words.txt`).split(/\r?\n/);
  for (const line of lines) {
    if (!line.includes('#')) {
      stats[sourceKey].skipped += 1;
      continue;
    }
    const idx = line.indexOf('#');
    const rawWord = line.slice(0, idx).trim();
    if (!rawWord || rawWord.includes(' ')) {
      stats[sourceKey].skipped += 1;
      continue;
    }

    const rest = line.slice(idx + 1).trim();
    const posMatch = rest.match(/^([a-z./]+)\s+/i);
    const pos = posMatch ? posMatch[1] : 'n.';
    const tail = posMatch ? rest.slice(posMatch[0].length) : rest;
    const def = tail.split(/[;；]/)[0].trim();

    addEntry(
      targetMap,
      stats,
      sourceKey,
      rawWord,
      pos,
      def,
      'TOEFL vocabulary'
    );
  }
}

function parseToeflFrom4300Csv(targetMap, stats) {
  const sourceKey = 'toefl_4300_csv';
  stats[sourceKey] = { added: 0, duplicates: 0, skipped: 0 };
  const lines = readText(`${SOURCES_DIR}/toefl_4300_word.csv`)
    .replace(/^\uFEFF/, '')
    .split(/\r?\n/);

  for (const line of lines) {
    const row = String(line || '').trim();
    if (!row || !row.includes(',')) {
      stats[sourceKey].skipped += 1;
      continue;
    }

    const idx = row.indexOf(',');
    const rawWord = row.slice(0, idx).trim();
    const rest = row.slice(idx + 1).trim();
    const posMatch = rest.match(/^([a-z]{1,6}\.)\s*/i);
    const pos = safePos((posMatch?.[1] || 'n.').toLowerCase());
    const def = safeDef(
      (posMatch ? rest.slice(posMatch[0].length) : rest).trim(),
      'TOEFL vocabulary supplement'
    );

    addEntry(
      targetMap,
      stats,
      sourceKey,
      rawWord,
      pos,
      def,
      'TOEFL vocabulary supplement'
    );
  }
}

function toSortedList(map) {
  return [...map.values()].sort((a, b) => a.word.localeCompare(b.word));
}

function writeJson(path, value) {
  fs.writeFileSync(path, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function updateManifest(cet4Count, cet6Count, ieltsCount, toeflCount, stats) {
  const path = `${ASSETS_DIR}/manifest.json`;
  const manifest = JSON.parse(readText(path));
  manifest.version = `${today()}-open-sources-v5`;
  manifest.generatedAt = today();
  manifest.source = 'open-source-mixed';

  manifest.wordbooks = (manifest.wordbooks || []).map((item) => {
    if (item.name === 'cet4') return { ...item, count: cet4Count, label: 'CET-4' };
    if (item.name === 'cet6') return { ...item, count: cet6Count, label: 'CET-6' };
    if (item.name === 'ielts') return { ...item, count: ieltsCount, label: 'IELTS' };
    if (item.name === 'toefl') return { ...item, count: toeflCount, label: 'TOEFL' };
    return item;
  });

  manifest.sourcesDetail = {
    cet4: ['ZE3kr/MemWords-CN cet4.csv (MIT, source file)'],
    cet6: ['mahavivo/english-wordlists CET6_edited.txt (public open source list)'],
    ielts: [
      'hefengxian/ielts-vocabulary (MIT)',
      'learning-zone/ielts-materials (MIT supplement)'
    ],
    toefl: [
      'ZE3kr/MemWords-CN word.csv (MIT, mirrored as toefl_4300_word.csv)',
      'ladrift/toefl (MIT)',
      'Lina-Liuna/Lina-Liuna.github.io (MIT supplement)'
    ],
    importStats: stats
  };

  writeJson(path, manifest);
}

function writeAttemptReport(cet4Count, cet6Count, ieltsCount, toeflCount) {
  const report = `# Requested Book Download Attempts (${today()})

This file records attempts for the requested sources and the final import decision.

## Requested Items

1. Cambridge Vocabulary for IELTS
Result: public mirrors found, but no official machine-readable source with clear redistribution terms. Not imported directly.

2. Collins Vocabulary for IELTS
Result: no stable machine-readable open source found in this run. Not imported directly.

3. Barron's Essential Words for IELTS
Result: no stable machine-readable open source found in this run. Not imported directly.

4. Barron's Essential Words for the TOEFL
Result: no stable machine-readable open source found in this run. Not imported directly.

5. TOEFL iBT Vocabulary Classified (~4200)
Result: partial classified materials found (MIT, Lina-Liuna), combined with open TOEFL list (MIT, ladrift) for coverage.

## Imported Sources

- CET-4: ZE3kr/MemWords-CN cet4.csv (MIT)
- CET-6: mahavivo/english-wordlists CET6_edited.txt
- IELTS: hefengxian/ielts-vocabulary (MIT) + learning-zone/ielts-materials (MIT)
- TOEFL: ZE3kr/MemWords-CN word.csv + ladrift/toefl (MIT) + Lina-Liuna/Lina-Liuna.github.io (MIT)

## Final Counts

- cet4.json: ${cet4Count} entries
- cet6.json: ${cet6Count} entries
- ielts.json: ${ieltsCount} entries
- toefl.json: ${toeflCount} entries
`;

  fs.writeFileSync(`${SOURCES_DIR}/BOOK_DOWNLOAD_ATTEMPTS.md`, report, 'utf8');
}

function main() {
  const stats = {};

  const cet4Map = new Map();
  parseCet4FromCsv(cet4Map, stats);
  const cet4List = toSortedList(cet4Map);

  const cet6Map = new Map();
  parseCet6FromEditedTxt(cet6Map, stats);
  const cet6List = toSortedList(cet6Map);

  const ieltsMap = new Map();
  parseIeltsFromHefengxian(ieltsMap, stats);
  parseIeltsFromLearningZone(ieltsMap, stats);
  const ieltsList = toSortedList(ieltsMap);

  const toeflMap = new Map();
  parseToeflFromLadrift(toeflMap, stats);
  parseToeflFrom4300Csv(toeflMap, stats);
  parseToeflFromQuestionJs(toeflMap, stats, 'toefl_power_vocab.js', 'lina_toefl_power');
  parseToeflFromQuestionJs(toeflMap, stats, 'toefl_quizdata.js', 'lina_toefl_quiz');
  const toeflList = toSortedList(toeflMap);

  writeJson(`${ASSETS_DIR}/cet4.json`, cet4List);
  writeJson(`${ASSETS_DIR}/cet6.json`, cet6List);
  writeJson(`${ASSETS_DIR}/ielts.json`, ieltsList);
  writeJson(`${ASSETS_DIR}/toefl.json`, toeflList);
  updateManifest(cet4List.length, cet6List.length, ieltsList.length, toeflList.length, stats);
  writeAttemptReport(cet4List.length, cet6List.length, ieltsList.length, toeflList.length);

  console.log(`CET-4 entries: ${cet4List.length}`);
  console.log(`CET-6 entries: ${cet6List.length}`);
  console.log(`IELTS entries: ${ieltsList.length}`);
  console.log(`TOEFL entries: ${toeflList.length}`);
  console.log('Import stats:');
  console.log(JSON.stringify(stats, null, 2));
}

main();
