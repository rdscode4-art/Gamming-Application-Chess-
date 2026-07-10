const express = require('express');
const controller = require('./userAdminController');

const router = express.Router();

const adminMiddleware = (req, res, next) => {
  next();
};

router.use(adminMiddleware);

router.get('/', controller.getUsers);
router.put('/:id/wallet', controller.updateUserWallet);
router.put('/:id/ban', controller.toggleBan);

module.exports = router;
