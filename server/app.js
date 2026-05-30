const express = require('express');
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcryptjs');
const { readCollection, writeCollection } = require('./utils/jsonDb');

const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const propertyRoutes = require('./routes/property.routes');
const favoriteRoutes = require('./routes/favorite.routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/favorites', favoriteRoutes);

app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', service: 'RoomMatch API' });
});

async function ensureSeedUserPassword() {
  const users = readCollection('users');
  const seed = users.find((u) => u.id === 'usr_001');
  if (!seed) return;

  const needsHash =
    !seed.passwordHash ||
    seed.passwordHash.includes('hashed_password') ||
    !seed.passwordHash.startsWith('$2');

  if (needsHash) {
    seed.passwordHash = await bcrypt.hash('password123', 10);
    writeCollection('users', users);
    console.log('Seed user usr_001 password set to: password123');
  }
}

ensureSeedUserPassword()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`RoomMatch API running at http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Failed to start server:', err);
    process.exit(1);
  });
