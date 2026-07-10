const Banner = require('../../models/Banner');

exports.getBanners = async (req, res, next) => {
  try {
    const banners = await Banner.find({ isActive: true }).sort({ order: 1 });
    res.status(200).json({ banners });
  } catch (error) {
    next(error);
  }
};
