import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const SOURCES_DIR = path.join(ROOT, 'data', 'sources');
const MANIFEST_PATH = path.join(SOURCES_DIR, 'SOURCE_FETCH_MANIFEST.json');

const SOURCE_ITEMS = [
  {
    category: 'data',
    target: 'ze3kr_cet4.csv',
    source: 'ZE3kr/MemWords-CN',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/ZE3kr/MemWords-CN/fa974dfe3ceb6cb65fec3b8ca87de3285d8891c1/cet4.csv'
  },
  {
    category: 'data',
    target: 'cet6_edited.txt',
    source: 'mahavivo/english-wordlists',
    license: 'UNSPECIFIED',
    url: 'https://raw.githubusercontent.com/mahavivo/english-wordlists/395cebd583d97be61b065d281d16dc49c7e4a8b0/CET6_edited.txt'
  },
  {
    category: 'data',
    target: 'ielts_vocabulary.js',
    source: 'hefengxian/ielts-vocabulary',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/hefengxian/ielts-vocabulary/d59669c8c55da843ce5996e3349e8cf0883c30db/vocabulary.js'
  },
  {
    category: 'data',
    target: 'learningzone_vocabulary.md',
    source: 'learning-zone/ielts-materials',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/learning-zone/ielts-materials/61cb945f8d5a9be4b4b8be8c03e37d60940df2ae/vocabulary.md'
  },
  {
    category: 'data',
    target: 'ladrift_toefl_words.txt',
    source: 'ladrift/toefl',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/ladrift/toefl/832ef58460242c32f8fbaa90face59c8dffc9ba1/words/wangyumei-toefl-words.txt'
  },
  {
    category: 'data',
    target: 'toefl_4300_word.csv',
    source: 'ZE3kr/MemWords-CN',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/ZE3kr/MemWords-CN/fa974dfe3ceb6cb65fec3b8ca87de3285d8891c1/word.csv'
  },
  {
    category: 'data',
    target: 'toefl_power_vocab.js',
    source: 'Lina-Liuna/Lina-Liuna.github.io',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/js/linked_TOEFL_Power_Vocab.js'
  },
  {
    category: 'data',
    target: 'toefl_quizdata.js',
    source: 'Lina-Liuna/Lina-Liuna.github.io',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/js/linked_quizdata.js'
  },
  {
    category: 'license',
    target: 'ielts_vocabulary.LICENSE',
    source: 'hefengxian/ielts-vocabulary',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/hefengxian/ielts-vocabulary/d59669c8c55da843ce5996e3349e8cf0883c30db/LICENSE'
  },
  {
    category: 'license',
    target: 'toefl_source.LICENSE',
    source: 'Lina-Liuna/Lina-Liuna.github.io',
    license: 'MIT',
    url: 'https://raw.githubusercontent.com/Lina-Liuna/Lina-Liuna.github.io/3407b6d38174bc93f669b1f3d61bcd42cba20763/LICENSE'
  }
];

function sha256(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

async function download(url) {
  const response = await fetch(url, {
    redirect: 'follow',
    headers: {
      'User-Agent': 'singword-source-fetcher'
    }
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  const arrayBuffer = await response.arrayBuffer();
  return Buffer.from(arrayBuffer);
}

async function main() {
  fs.mkdirSync(SOURCES_DIR, { recursive: true });

  const generatedAt = new Date().toISOString();
  const rows = [];

  for (const item of SOURCE_ITEMS) {
    const targetPath = path.join(SOURCES_DIR, item.target);
    const oldBuffer = fs.existsSync(targetPath) ? fs.readFileSync(targetPath) : null;
    const oldSha = oldBuffer ? sha256(oldBuffer) : null;

    const buffer = await download(item.url);
    if (buffer.length === 0) {
      throw new Error(`Downloaded empty file: ${item.target}`);
    }

    const newSha = sha256(buffer);
    fs.writeFileSync(targetPath, buffer);

    const changed = oldSha !== newSha;
    const flag = changed ? 'UPDATED' : 'UNCHANGED';
    console.log(`${flag} ${item.target} (${buffer.length} bytes)`);

    rows.push({
      category: item.category,
      target: item.target,
      source: item.source,
      license: item.license,
      url: item.url,
      bytes: buffer.length,
      sha256: newSha,
      changed
    });
  }

  const manifest = {
    generatedAt,
    sourceCount: rows.length,
    rows
  };
  fs.writeFileSync(MANIFEST_PATH, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
  console.log(`Wrote ${path.relative(ROOT, MANIFEST_PATH)}`);
}

main().catch((err) => {
  console.error(`Source fetch failed: ${err.message}`);
  process.exit(1);
});
