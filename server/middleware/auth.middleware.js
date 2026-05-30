const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'roommatch_dev_secret_change_in_production';

function authRequired(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

function ownerRequired(req, res, next) {
  if (req.user?.role !== 'owner') {
    return res.status(403).json({ message: 'Owner access required' });
  }
  next();
}

module.exports = { authRequired, ownerRequired, JWT_SECRET };
