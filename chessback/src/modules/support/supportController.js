const SupportTicket = require('../../models/SupportTicket');
const { v4: uuidv4 } = require('uuid');

exports.createTicket = async (req, res, next) => {
  try {
    const { category, subject, description } = req.body;

    if (!category || !subject || !description) {
      return res.status(400).json({ message: 'Category, subject, and description are required' });
    }

    const ticketId = `TKT-${uuidv4().split('-')[0].toUpperCase()}`;

    const newTicket = await SupportTicket.create({
      ticketId,
      userId: req.user.userId,
      category,
      subject,
      description,
      status: 'open',
      priority: 'medium',
      replies: [{
        authorId: req.user.userId,
        authorRole: 'user',
        message: description
      }]
    });

    res.status(201).json({ message: 'Ticket created successfully', ticket: newTicket });
  } catch (error) {
    next(error);
  }
};

exports.getMyTickets = async (req, res, next) => {
  try {
    const tickets = await SupportTicket.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    res.status(200).json({ tickets });
  } catch (error) {
    next(error);
  }
};
