const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { readCollection, writeCollection } = require('../utils/jsonDb');
const { generateId } = require('../utils/ids');
const { sanitizeUser } = require('../utils/userResponse');
const { JWT_SECRET } = require('../middleware/auth.middleware');

function signToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: '7d' },
  );
}

async function register(req, res) {
  try {
    const { fullName, email, phone, password, gender, role } = req.body;

    if (!fullName?.trim() || !email?.trim() || !password) {
      return res.status(400).json({ message: 'Full name, email, and password are required' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    const users = readCollection('users');
    const normalizedEmail = email.trim().toLowerCase();

    if (users.some((u) => u.email.toLowerCase() === normalizedEmail)) {
      return res.status(409).json({ message: 'Email already registered' });
    }

    const userRole = role === 'tenant' ? 'tenant' : 'owner';
    const passwordHash = await bcrypt.hash(password, 10);

    const user = {
      id: generateId('usr'),
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone?.trim() || '',
      passwordHash,
      gender: gender || 'Male',
      role: userRole,
      avatarUrl: '',
      bio: '',
      createdAt: new Date().toISOString(),
    };

    users.push(user);
    writeCollection('users', users);

    const token = signToken(user);
    return res.status(201).json({
      token,
      user: sanitizeUser(user),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Registration failed' });
  }
}

async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email?.trim() || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const users = readCollection('users');
    const user = users.find((u) => u.email.toLowerCase() === email.trim().toLowerCase());

    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const token = signToken(user);
    return res.json({
      token,
      user: sanitizeUser(user),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Login failed' });
  }
}

module.exports = { register, login };
