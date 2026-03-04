import fs from 'node:fs';

const ROOT = process.cwd();
const WORDBOOK_DIR = `${ROOT}/android/app/src/main/assets/wordbooks`;
const REQUIRED_BOOKS = ['cet4', 'cet6', 'ielts', 'toefl'];
const MIN_COUNTS = {
  cet4: 200,
  cet6: 200,
  ielts: 200,
  toefl: 200
};

function fail(message) {
  console.error(`❌ ${message}`);
  process.exitCode = 1;
}

function ok(message) {
  console.log(`✅ ${message}`);
}

function readJson(path) {
  try {
    return JSON.parse(fs.readFileSync(path, 'utf8'));
  } catch (e) {
    fail(`无法解析 JSON: ${path} (${e.message})`);
    return null;
  }
}

function normalizeWord(raw) {
  return String(raw || '')
    .replace(/’/g, "'")
    .toLowerCase()
    .replace(/'/g, '')
    .replace(/[^a-z]/g, '')
    .trim();
}

function checkBook(book, list) {
  if (!Array.isArray(list)) {
    fail(`${book}.json 不是数组`);
    return { count: 0 };
  }

  if (list.length < MIN_COUNTS[book]) {
    fail(`${book}.json 词量过低: ${list.length} (< ${MIN_COUNTS[book]})`);
  }

  const seen = new Set();
  let prevWord = '';
  let badItemCount = 0;

  for (let i = 0; i < list.length; i += 1) {
    const row = list[i];
    if (!row || typeof row !== 'object') {
      badItemCount += 1;
      continue;
    }
    const word = String(row.word || '').trim();
    const pos = String(row.pos || '').trim();
    const def = String(row.def || '').trim();
    if (!word || !pos || !def) {
      badItemCount += 1;
      continue;
    }

    const normalized = normalizeWord(word);
    if (!normalized) {
      badItemCount += 1;
      continue;
    }

    if (seen.has(normalized)) {
      fail(`${book}.json 出现重复词: ${normalized}`);
    }
    seen.add(normalized);

    if (prevWord && normalized < prevWord) {
      fail(`${book}.json 未按字母排序: ${prevWord} > ${normalized}`);
      break;
    }
    prevWord = normalized;
  }

  if (badItemCount > 0) {
    fail(`${book}.json 存在 ${badItemCount} 条格式异常记录`);
  }

  return { count: list.length };
}

function main() {
  const manifestPath = `${WORDBOOK_DIR}/manifest.json`;
  const manifest = readJson(manifestPath);
  if (!manifest) {
    process.exit(1);
  }

  if (!Array.isArray(manifest.wordbooks)) {
    fail('manifest.json 缺少 wordbooks 数组');
    process.exit(1);
  }

  const manifestByName = new Map(
    manifest.wordbooks
      .filter((x) => x && typeof x === 'object')
      .map((x) => [String(x.name || ''), x])
  );

  if (!manifest.sourcesDetail || typeof manifest.sourcesDetail !== 'object') {
    fail('manifest.json 缺少 sourcesDetail');
  }

  const counts = {};
  for (const book of REQUIRED_BOOKS) {
    const path = `${WORDBOOK_DIR}/${book}.json`;
    if (!fs.existsSync(path)) {
      fail(`缺少词表文件: ${path}`);
      continue;
    }
    const list = readJson(path);
    if (!list) continue;

    const { count } = checkBook(book, list);
    counts[book] = count;
    ok(`${book}.json 检查通过 (${count} 条)`);

    const manifestItem = manifestByName.get(book);
    if (!manifestItem) {
      fail(`manifest.json 缺少 ${book} 条目`);
      continue;
    }
    if (Number(manifestItem.count) !== count) {
      fail(`manifest ${book} count=${manifestItem.count} 与实际=${count} 不一致`);
    }
  }

  if (!process.exitCode) {
    ok(
      `词表校验通过: ${REQUIRED_BOOKS.map((book) => `${book}=${counts[book]}`).join(', ')}`
    );
  } else {
    console.error('Wordbook verification failed.');
  }
}

main();
