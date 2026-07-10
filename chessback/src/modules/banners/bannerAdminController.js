const Banner = require('../../models/Banner');

exports.getBanners = async (req, res, next) => {
  try {
    const banners = await Banner.find().sort({ order: 1 });
    res.json(banners);
  } catch (error) { next(error); }
};

exports.createBanner = async (req, res, next) => {
  try {
    const newBanner = await Banner.create(req.body);
    res.status(201).json(newBanner);
  } catch (error) { next(error); }
};

exports.updateBanner = async (req, res, next) => {
  try {
    const updatedBanner = await Banner.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updatedBanner);
  } catch (error) { next(error); }
};

exports.deleteBanner = async (req, res, next) => {
  try {
    await Banner.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted successfully' });
  } catch (error) { next(error); }
};
