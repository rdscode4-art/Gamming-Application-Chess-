const SystemSetting = require('../../models/SystemSetting');

// ─── Admin Endpoints ────────────────────────────────────────────────────────

exports.getAllSettings = async (req, res, next) => {
  try {
    const settings = await SystemSetting.find();
    res.status(200).json({ settings });
  } catch (error) {
    next(error);
  }
};

exports.updateSetting = async (req, res, next) => {
  try {
    const { key } = req.params;
    const { value, description } = req.body;

    let setting = await SystemSetting.findOne({ key });
    if (!setting) {
      setting = new SystemSetting({ key, value, description });
    } else {
      setting.value = value;
      if (description !== undefined) {
        setting.description = description;
      }
    }

    await setting.save();
    res.status(200).json({ message: 'Setting updated successfully', setting });
  } catch (error) {
    next(error);
  }
};

// ─── Public Endpoints ───────────────────────────────────────────────────────

exports.getPublicSettings = async (req, res, next) => {
  try {
    // List of keys safe to expose to the public frontend
    const publicKeys = [
      'referral_reward_amount',
      'terms_conditions',
      'privacy_policy',
      'responsible_gaming'
    ];
    
    const settings = await SystemSetting.find({ key: { $in: publicKeys } });
    
    // Transform array to a key-value object for easier consumption
    const config = {};
    settings.forEach(s => {
      config[s.key] = s.value;
    });

    // Provide defaults if not set in DB
    if (!config['referral_reward_amount']) config['referral_reward_amount'] = 50; 
    if (!config['terms_conditions']) config['terms_conditions'] = 'Official Terms and Conditions for Checkmate.\n\nPlease read carefully...'; 
    if (!config['privacy_policy']) config['privacy_policy'] = 'Privacy Policy for Checkmate.\n\nYour data is secure...'; 
    if (!config['responsible_gaming']) config['responsible_gaming'] = 'Responsible Gaming.\n\nPlay safely...'; 

    res.status(200).json({ settings: config });
  } catch (error) {
    next(error);
  }
};
