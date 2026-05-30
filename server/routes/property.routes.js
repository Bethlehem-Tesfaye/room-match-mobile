const express = require('express');
const {
  listProperties,
  getProperty,
  createProperty,
  updateProperty,
  deleteProperty,
} = require('../controllers/property.controller');
const { authRequired, ownerRequired } = require('../middleware/auth.middleware');
const { uploadPropertyImages } = require('../middleware/upload.middleware');

const router = express.Router();

router.get('/', listProperties);
router.get('/:id', getProperty);
router.post('/', authRequired, ownerRequired, uploadPropertyImages, createProperty);
router.put('/:id', authRequired, ownerRequired, uploadPropertyImages, updateProperty);
router.delete('/:id', authRequired, ownerRequired, deleteProperty);

module.exports = router;
