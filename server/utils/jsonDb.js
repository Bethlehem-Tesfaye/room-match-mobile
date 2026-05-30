const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');

function filePath(name) {
  return path.join(dataDir, `${name}.json`);
}

function readCollection(name) {
  const raw = fs.readFileSync(filePath(name), 'utf8');
  return JSON.parse(raw);
}

function writeCollection(name, data) {
  fs.writeFileSync(filePath(name), JSON.stringify(data, null, 2), 'utf8');
}

module.exports = { readCollection, writeCollection };
