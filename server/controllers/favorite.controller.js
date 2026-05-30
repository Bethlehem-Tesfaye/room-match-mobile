const { readCollection, writeCollection } = require('../utils/jsonDb');
const { generateId } = require('../utils/ids');

function getUserFavorites(req, res) {
  try {
    const { userId } = req.params;
    const favorites = readCollection('favorites').filter((f) => f.userId === userId);
    const properties = readCollection('properties');

    const result = favorites
      .map((fav) => properties.find((p) => p.id === fav.propertyId))
      .filter(Boolean)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    return res.json(result);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch favorites' });
  }
}

function addFavorite(req, res) {
  try {
    const { userId, propertyId } = req.body;

    if (!userId || !propertyId) {
      return res.status(400).json({ message: 'userId and propertyId are required' });
    }

    const properties = readCollection('properties');
    const property = properties.find((p) => p.id === propertyId);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    const favorites = readCollection('favorites');
    const exists = favorites.some(
      (f) => f.userId === userId && f.propertyId === propertyId,
    );

    if (exists) {
      return res.status(200).json(property);
    }

    const favorite = {
      id: generateId('fav'),
      userId,
      propertyId,
      createdAt: new Date().toISOString(),
    };

    favorites.push(favorite);
    writeCollection('favorites', favorites);

    return res.status(201).json(property);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to add favorite' });
  }
}

function removeFavorite(req, res) {
  try {
    const { userId, propertyId } = req.params;
    const favorites = readCollection('favorites');
    const index = favorites.findIndex(
      (f) => f.userId === userId && f.propertyId === propertyId,
    );

    if (index === -1) {
      return res.status(404).json({ message: 'Favorite not found' });
    }

    favorites.splice(index, 1);
    writeCollection('favorites', favorites);

    return res.json({ message: 'Favorite removed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to remove favorite' });
  }
}

module.exports = { getUserFavorites, addFavorite, removeFavorite };
