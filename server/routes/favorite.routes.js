const express = require('express');
const {
  getUserFavorites,
  addFavorite,
  removeFavorite,
} = require('../controllers/favorite.controller');

const router = express.Router();

router.get('/:userId', getUserFavorites);
router.post('/', addFavorite);
router.delete('/:userId/:propertyId', removeFavorite);

module.exports = router;
