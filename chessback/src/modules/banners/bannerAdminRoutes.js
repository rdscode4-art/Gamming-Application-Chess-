const express = require('express');
const controller = require('./bannerAdminController');

const router = express.Router();

const adminMiddleware = (req, res, next) => {
  next();
};

router.use(adminMiddleware);

router.get('/', controller.getBanners);
router.post('/', controller.createBanner);
router.put('/:id', controller.updateBanner);
router.delete('/:id', controller.deleteBanner);

module.exports = router;
