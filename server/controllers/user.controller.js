const { readCollection, writeCollection } = require('../utils/jsonDb');
const { sanitizeUser } = require('../utils/userResponse');

function getUser(req, res) {
  try {
    const users = readCollection('users');
    const user = users.find((u) => u.id === req.params.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json(sanitizeUser(user));
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch user' });
  }
}

function updateUser(req, res) {
  try {
    if (req.user.id !== req.params.id) {
      return res.status(403).json({ message: 'You can only update your own profile' });
    }

    const users = readCollection('users');
    const index = users.findIndex((u) => u.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ message: 'User not found' });
    }

    const { fullName, email, phone, bio, gender } = req.body;
    const user = users[index];

    if (fullName !== undefined) user.fullName = String(fullName).trim();
    if (phone !== undefined) user.phone = String(phone).trim();
    if (bio !== undefined) user.bio = String(bio).trim();
    if (gender !== undefined) user.gender = gender;

    if (email !== undefined) {
      const normalized = String(email).trim().toLowerCase();
      const taken = users.some(
        (u, i) => i !== index && u.email.toLowerCase() === normalized,
      );
      if (taken) {
        return res.status(409).json({ message: 'Email already in use' });
      }
      user.email = normalized;
    }

    if (req.file) {
      user.avatarUrl = `/uploads/${req.file.filename}`;
    }

    users[index] = user;
    writeCollection('users', users);

    return res.json(sanitizeUser(user));
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to update user' });
  }
}

module.exports = { getUser, updateUser };
