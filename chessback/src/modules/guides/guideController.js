const ChessGuide = require('../../models/ChessGuide');
const path = require('path');
const fs = require('fs');

// Public route to fetch all guides
exports.getAllGuides = async (req, res) => {
  try {
    const guides = await ChessGuide.find().sort({ order: 1 });
    res.status(200).json({ status: 'success', data: guides });
  } catch (error) {
    console.error('Error fetching guides:', error);
    res.status(500).json({ status: 'error', message: 'Failed to fetch guides' });
  }
};

// Admin route to create a guide
exports.createGuide = async (req, res) => {
  try {
    const { title, content, mediaType, mediaUrl, order } = req.body;
    
    let finalMediaUrl = mediaUrl;
    if (req.file) {
      // If a file was uploaded, construct the URL
      finalMediaUrl = `/guides/${req.file.filename}`;
    }

    const newGuide = new ChessGuide({
      title,
      content,
      mediaType,
      mediaUrl: finalMediaUrl,
      order: order || 0
    });

    await newGuide.save();
    res.status(201).json({ status: 'success', data: newGuide });
  } catch (error) {
    console.error('Error creating guide:', error);
    res.status(500).json({ status: 'error', message: 'Failed to create guide' });
  }
};

// Admin route to update a guide
exports.updateGuide = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, mediaType, mediaUrl, order } = req.body;
    
    const guide = await ChessGuide.findById(id);
    if (!guide) {
      return res.status(404).json({ status: 'error', message: 'Guide not found' });
    }

    let finalMediaUrl = mediaUrl !== undefined ? mediaUrl : guide.mediaUrl;
    
    // If a new file is uploaded
    if (req.file) {
      finalMediaUrl = `/guides/${req.file.filename}`;
      // Optional: Delete old file if it was a local upload
      if (guide.mediaUrl && guide.mediaUrl.startsWith('/guides/')) {
        const oldFilePath = path.join(__dirname, '..', '..', '..', 'public', guide.mediaUrl);
        if (fs.existsSync(oldFilePath)) {
          fs.unlinkSync(oldFilePath);
        }
      }
    }

    guide.title = title || guide.title;
    guide.content = content || guide.content;
    guide.mediaType = mediaType || guide.mediaType;
    guide.mediaUrl = finalMediaUrl;
    guide.order = order !== undefined ? order : guide.order;

    await guide.save();
    res.status(200).json({ status: 'success', data: guide });
  } catch (error) {
    console.error('Error updating guide:', error);
    res.status(500).json({ status: 'error', message: 'Failed to update guide' });
  }
};

// Admin route to delete a guide
exports.deleteGuide = async (req, res) => {
  try {
    const { id } = req.params;
    const guide = await ChessGuide.findById(id);
    if (!guide) {
      return res.status(404).json({ status: 'error', message: 'Guide not found' });
    }

    // Delete local media if it exists
    if (guide.mediaUrl && guide.mediaUrl.startsWith('/guides/')) {
      const oldFilePath = path.join(__dirname, '..', '..', '..', 'public', guide.mediaUrl);
      if (fs.existsSync(oldFilePath)) {
        fs.unlinkSync(oldFilePath);
      }
    }

    await guide.deleteOne();
    res.status(200).json({ status: 'success', message: 'Guide deleted successfully' });
  } catch (error) {
    console.error('Error deleting guide:', error);
    res.status(500).json({ status: 'error', message: 'Failed to delete guide' });
  }
};
