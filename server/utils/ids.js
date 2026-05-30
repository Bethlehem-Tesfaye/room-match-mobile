function generateId(prefix) {
  const suffix = Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
  return `${prefix}_${suffix}`;
}

module.exports = { generateId };
