const express = require('express');
const { getUser, updateUser } = require('../controllers/user.controller');
const { authRequired } = require('../middleware/auth.middleware');
const { uploadAvatar } = require('../middleware/upload.middleware');

const router = express.Router();

router.get('/:id', getUser);
router.put('/:id', authRequired, uploadAvatar, updateUser);

module.exports = router;
