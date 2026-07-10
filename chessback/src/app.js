const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { errorHandler } = require('./middleware/errorMiddleware');

const app = express();

// ─── Security Middlewares ──────────────────────────────────────────────────
app.use(helmet());

app.use(cors({
  origin: [process.env.CLIENT_URL || '*', 'http://localhost:5173'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// ─── Rate Limiting ─────────────────────────────────────────────────────────
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests from this IP, please try again after 15 minutes',
  standardHeaders: true,
  legacyHeaders: false,
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20, // stricter for auth routes
  message: 'Too many auth attempts, please try again later',
});

app.use('/api/', apiLimiter);
app.use('/api/auth/', authLimiter);

// ─── Body Parser ──────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ─── Routes ───────────────────────────────────────────────────────────────
const authRoutes = require('./modules/auth/authRoutes');
const leaderboardRoutes = require('./modules/leaderboard/leaderboardRoutes');
const userRoutes = require('./modules/users/userRoutes');
const contestRoutes = require('./modules/matchmaking/contestRoutes');
const walletRoutes = require('./modules/wallet/walletRoutes');
const tournamentRoutes = require('./modules/tournaments/tournamentRoutes');
const bannerRoutes = require('./modules/banners/bannerRoutes');
const gameModeAdminRoutes = require('./modules/matchmaking/gameModeAdminRoutes');
const bannerAdminRoutes = require('./modules/banners/bannerAdminRoutes');
const tournamentAdminRoutes = require('./modules/tournaments/tournamentAdminRoutes');
const userAdminRoutes = require('./modules/users/userAdminRoutes');

app.get('/', (req, res) => res.status(200).send(`<h1>🚀 Chess Platform Backend is running!</h1>`));
app.get('/health', (req, res) => res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() }));

app.use('/api/auth', authRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/users', userRoutes);
app.use('/api/contests', contestRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/tournaments', tournamentRoutes);
app.use('/api/banners', bannerRoutes);

// Admin Routes (Modularized)
app.use('/api/admin/gamemodes', gameModeAdminRoutes);
app.use('/api/admin/banners', bannerAdminRoutes);
app.use('/api/admin/tournaments', tournamentAdminRoutes);
app.use('/api/admin/users', userAdminRoutes);

// ─── Error Handler ────────────────────────────────────────────────────────
app.use(errorHandler);

module.exports = app;
