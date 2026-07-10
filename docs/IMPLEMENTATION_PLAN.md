# Chess Gaming Platform — Full Implementation Plan

> **Project:** Real Money Multiplayer Chess Platform
> **Stack:** Flutter (GetX) + Node.js + Socket.IO + MongoDB + Razorpay + Firebase
> **Status:** Active Development
> **Current State:** Auth ✅ | Basic Game ✅ | Matchmaking ✅ | Leaderboard (partial) ✅

---

## 🔖 Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Already implemented |
| 🔄 | Partially implemented |
| ⬜ | Not started |

---

## PHASE 1 — Foundation & Core Infrastructure (Week 1–2)

> Fix existing issues and solidify the base before building new features.

### 1.1 Socket / Live Connection Fix ⬜
- [ ] Fix Socket.IO transport=polling → websocket upgrade issue on production Apache
- [ ] Add Apache/Nginx WebSocket proxy headers (Upgrade, Connection: upgrade)
- [ ] Add reconnect logic with exponential backoff in socket_service.dart
- [ ] Show user-facing "Connecting…" / "Disconnected" banner UI

### 1.2 Auth Module Hardening 🔄
- [ ] JWT refresh token flow (access token expires in 15m, refresh in 7d)
- [ ] Logout from all devices endpoint
- [ ] Secure token storage (FlutterSecureStorage instead of SharedPreferences)
- [ ] Phone number OTP login (for Indian market — SMS via Twilio/MSG91)
- [ ] Google Sign-In support
- [ ] Email verification flow
- [ ] Password reset via OTP

### 1.3 User Profile Module ⬜

**Backend (/modules/users):**
- [ ] GET /api/users/me — full profile with stats
- [ ] PUT /api/users/me — update avatar, display name
- [ ] GET /api/users/:id — public profile
- [ ] Avatar upload (Cloudinary / S3 / local)
- [ ] Player ID generation (unique short ID like #CHESS1234)

**Flutter (/features/profile):**
- [ ] Profile screen UI with avatar, rating, stats cards
- [ ] Edit profile bottom sheet
- [ ] Match history list on profile
- [ ] Achievements & badges section (placeholder for Phase 5)

### 1.4 Database Schema Finalization ⬜
- [ ] User model — add: phoneNumber, referralCode, referredBy, avatarUrl, playerId, isKycVerified, isBanned
- [ ] Game model — add: contestType, entryFee, prizePool, timeControl, rated
- [ ] Transaction model — new (for wallet)
- [ ] Tournament model — new
- [ ] TournamentMatch model — new
- [ ] Wallet model — new
- [ ] Notification model — new
- [ ] SupportTicket model — new
- [ ] AuditLog model — new

---

## PHASE 2 — Chess Gameplay Completion (Week 2–3)

> The board renders but game logic needs to be production-grade.

### 2.1 Chess Clock (Timer) ✅ → ⬜
- [x] Basic clock exists in clockManager.js
- [ ] Fix clock sync issues on reconnect
- [ ] Send clock state in every move event so Flutter can sync
- [ ] Display both clocks (player + opponent) on game screen
- [ ] Low-time warning (shake / color change when < 10 seconds)
- [ ] timeout event → auto-forfeit and prize distribution

### 2.2 Game Time Controls ⬜
- [ ] Support all time controls:
  - Classic: 15+10, 30+0, 60+0 (minutes + increment)
  - Rapid: 3+2, 5+0, 5+3, 10+0 (minutes + increment)
- [ ] Pass timeControl + increment in matchmaking queue
- [ ] Backend validates and starts clock with correct params

### 2.3 Game End Scenarios ⬜
- [ ] Checkmate detection ✅ (chess.js)
- [ ] Stalemate / Draw detection ✅ (chess.js)
- [ ] Resign button with confirmation dialog
- [ ] Timeout auto-resign
- [ ] Draw offer — send / accept / reject
- [ ] Threefold repetition draw
- [ ] 50-move rule draw
- [ ] Show "Game Over" modal with result, prize earned, rating change

### 2.4 Reconnect Support ⬜
- [ ] Backend stores in-progress game state in Redis
- [ ] On reconnect: rejoin_game event → receive full game state (FEN, clocks, moves)
- [ ] Flutter detects network loss → shows reconnect banner
- [ ] Auto-reconnect on network restore (max 3 retries, then forfeit timer)
- [ ] Opponent gets "Opponent disconnected" notice with countdown

### 2.5 Match History ⬜

**Backend:**
- [ ] GET /api/games/history?userId=&page=&limit= — paginated
- [ ] Include: result, opponent name, time control, ELO change, date

**Flutter:**
- [ ] Match history screen with filter (Win/Loss/Draw)
- [ ] Each card shows: opponent avatar, result badge, ELO delta, time played

### 2.6 Spectator Mode ⬜
- [ ] spectate_game socket event
- [ ] Read-only board view
- [ ] View ongoing public matches from lobby

---

## PHASE 3 — Matchmaking & Contest System (Week 3–4)

### 3.1 Enhanced Matchmaking ✅ → ⬜
- [x] Basic 1v1 queue exists
- [ ] Match by ELO range (±200 points, expand every 30s)
- [ ] Match by time control
- [ ] Match by contest type (free / paid)
- [ ] Queue status screen ("Searching… 00:34")
- [ ] Cancel matchmaking button

### 3.2 Contest Types ⬜

**Backend (/modules/contests):**
- [ ] POST /api/contests/create — create public/private contest
- [ ] GET /api/contests — list open contests
- [ ] POST /api/contests/:id/join — join with wallet deduction
- [ ] GET /api/contests/:id — contest details

**Contest Types to support:**
- [ ] Free Match — no entry fee, no real money
- [ ] Paid 1v1 — fixed entry fee (₹10, ₹25, ₹50, ₹100, ₹500)
- [ ] Public Contest — anyone can join up to N players
- [ ] Private Contest — invite-only via code
- [ ] Rated Match — affects ELO rating
- [ ] Unrated Match — practice, no ELO change

**Flutter (/features/contests):**
- [ ] Lobby screen — tabs: Quick Match | Contests | Tournaments
- [ ] Contest card UI (entry fee, prize pool, players joined, time control)
- [ ] Create contest bottom sheet
- [ ] Join contest confirmation with wallet balance check
- [ ] Private contest — enter invite code flow

### 3.3 Prize Pool & Platform Fee ⬜
- [ ] Prize pool = sum of all entry fees
- [ ] Platform commission % (configurable in admin, e.g., 10%)
- [ ] Winner gets: prizePool * (1 - platformFee%)
- [ ] Auto-distribute on game end via walletService.credit()
- [ ] Handle ties (split prize)

---

## PHASE 4 — Wallet & Payment System (Week 4–5)

### 4.1 Wallet Backend ⬜

**Module: /modules/wallet**
- [ ] Wallet model: userId, depositBalance, winningsBalance, bonusBalance, totalBalance
- [ ] Transaction model: userId, type (deposit/withdrawal/prize/refund/bonus), amount, status, razorpayId, createdAt
- [ ] GET /api/wallet — get balances
- [ ] GET /api/wallet/transactions?page=&limit= — history
- [ ] POST /api/wallet/deposit/initiate — create Razorpay order
- [ ] POST /api/wallet/deposit/verify — verify Razorpay payment signature → credit wallet
- [ ] POST /api/wallet/withdraw — initiate withdrawal (requires KYC)
- [ ] Atomic transactions using MongoDB sessions (no race conditions)
- [ ] Lock balance during active contest (prevent double-spend)

### 4.2 Razorpay Integration ⬜
- [ ] Install razorpay Node.js SDK
- [ ] Create Razorpay order server-side (amount in paise)
- [ ] Sign & verify payment signature using crypto.createHmac
- [ ] Webhook handler for async payment confirmation
- [ ] Razorpay Test vs Live mode config via .env

**Flutter:**
- [ ] Install razorpay_flutter package
- [ ] WalletController — fetch balance, initiate deposit, open Razorpay checkout
- [ ] Handle payment success / failure callbacks
- [ ] Wallet screen — balance cards + add money button + history list

### 4.3 Withdrawal System ⬜
- [ ] Only winningsBalance can be withdrawn (not bonus)
- [ ] Minimum withdrawal ₹100
- [ ] Bank account / UPI details collection
- [ ] Admin approval workflow for withdrawals > ₹5000
- [ ] Auto-payout via Razorpay Payouts API (or manual for now)

### 4.4 Referral & Bonus System ⬜
- [ ] Unique referral code per user
- [ ] On signup with referral code → bonus credited (e.g., ₹25 to referrer, ₹25 to new user)
- [ ] Bonus balance — can only be used as entry fee, cannot be withdrawn
- [ ] Referral history screen

---

## PHASE 5 — ELO Rating & Leaderboards (Week 5–6)

### 5.1 ELO Rating Engine ⬜

**Backend (/modules/rating):**
- [ ] ELO calculation on every rated game end
- [ ] Separate ELO for Classic and Rapid
- [ ] Starting ELO: 1200
- [ ] K-factor: 32 (< 2100 rating) / 24 (2100–2400) / 16 (> 2400)
- [ ] Store ELO history as array for sparkline chart
- [ ] Update User.classicRating and User.rapidRating post-game

### 5.2 Leaderboards 🔄

**Backend 🔄 (/modules/leaderboard):**
- [ ] Global leaderboard (all-time) — partially done
- [ ] Daily, Weekly, Monthly leaderboards (use scheduled cron jobs)
- [ ] Separate board for Classic and Rapid
- [ ] Tournament champion rankings
- [ ] Cache with Redis (refresh every 5 minutes)

**Flutter 🔄:**
- [ ] Leaderboard screen with tab bar: All-Time | Monthly | Weekly | Daily
- [ ] Sub-tabs: Classic | Rapid
- [ ] Current user rank highlight
- [ ] Tap user → navigate to public profile

### 5.3 Achievements & Badges ⬜
- [ ] Define badge catalog: "First Win", "10-Game Streak", "Tournament Champion", "Top 10 Ranker", etc.
- [ ] Badge evaluation cron job / event-driven trigger
- [ ] Show on profile
- [ ] Push notification on badge unlock

---

## PHASE 6 — Tournament System (Week 6–8)

### 6.1 Tournament Backend ⬜

**Module: /modules/tournament**

**Tournament model fields:**
- name, format (knockout/swiss), timeControl, entryFee, prizePool
- maxPlayers (4/8/16/32/64/custom), registeredPlayers[]
- status (upcoming/registration/ongoing/completed)
- startTime, inviteCode, isPrivate, createdBy (admin/user)
- rounds[] → matches[]

**API Routes:**
- [ ] POST /api/tournaments — create (admin or user-created)
- [ ] GET /api/tournaments — list with filters (upcoming/ongoing/my)
- [ ] POST /api/tournaments/:id/register — register with fee deduction
- [ ] POST /api/tournaments/:id/start — admin starts (auto-bracket generation)
- [ ] GET /api/tournaments/:id/bracket — full bracket data

### 6.2 Tournament Formats ⬜

**Knockout (Single Elimination):**
- [ ] Auto-generate rounds (Round of 8 → QF → SF → Final)
- [ ] Bye handling for odd player counts
- [ ] Winner advances, loser is eliminated
- [ ] Auto-start next round when all matches in current round done

**Swiss Format:**
- [ ] Pair players by score each round
- [ ] No elimination — all play N rounds
- [ ] Final standings by score + tiebreaks (Buchholz)
- [ ] Suitable for large player pools

### 6.3 Private & Invite Tournaments ⬜
- [ ] User-created private tournaments
- [ ] Generate unique 6-char invite code
- [ ] Shareable invite link: chess.app/tournament/join/{code}
- [ ] Scheduled start date/time picker

### 6.4 Tournament Flutter UI ⬜
- [ ] Tournament listing screen (cards: name, entry, prize, players, time)
- [ ] Tournament detail screen (info + bracket)
- [ ] Live bracket viewer
- [ ] Register button with fee confirmation
- [ ] Create tournament form (admin + user)
- [ ] My tournaments tab (registered, created, completed)

---

## PHASE 7 — Notification System (Week 8–9)

### 7.1 Firebase Cloud Messaging (FCM) ⬜

**Backend:**
- [ ] Install firebase-admin SDK
- [ ] POST /api/notifications/register — store FCM token per device
- [ ] notificationService.send(userId, title, body, data) utility

**Notification triggers:**
- [ ] Match found → opponent's device
- [ ] Tournament about to start (30 min, 5 min reminders)
- [ ] Wallet credited (deposit/prize)
- [ ] Withdrawal approved/rejected
- [ ] Badge unlocked
- [ ] Friend request / invite received

**Flutter:**
- [ ] firebase_messaging package setup
- [ ] Request notification permission on first launch
- [ ] Handle foreground / background / terminated notification tap
- [ ] Navigate to correct screen based on notification type in payload

### 7.2 In-App Notification Center ⬜
- [ ] Notification bell icon in app bar with unread count badge
- [ ] Notification list screen (mark all as read)
- [ ] Grouped by date
- [ ] Store notifications in Notification model in DB

---

## PHASE 8 — Social Features (Week 9–10)

### 8.1 Friend System ⬜

**Backend (/modules/friends):**
- [ ] POST /api/friends/request/:userId
- [ ] POST /api/friends/accept/:requestId
- [ ] POST /api/friends/decline/:requestId
- [ ] DELETE /api/friends/:userId — unfriend
- [ ] GET /api/friends — friend list with online status
- [ ] GET /api/friends/requests — pending requests

**Flutter:**
- [ ] Friends tab in profile
- [ ] Search users by Player ID
- [ ] Friend request send/accept/decline
- [ ] Challenge friend to private match

### 8.2 Private Match Invite ⬜
- [ ] POST /api/invites/send — send invite to friend
- [ ] Socket event: game_invite_received → friend gets popup
- [ ] Accept → both joined to game room instantly
- [ ] Decline → notification to sender

### 8.3 Referral Program ⬜
- [ ] Referral screen with: user's code + share button
- [ ] Referral tree (direct + indirect)
- [ ] Referral reward history
- [ ] Share via WhatsApp / native share sheet

---

## PHASE 9 — Support System (Week 10–11)

### 9.1 Backend ⬜

**Module: /modules/support**

**SupportTicket model:** userId, category, subject, description, status, attachments[], adminReplies[]

**Routes:**
- [ ] POST /api/support/tickets — raise ticket
- [ ] GET /api/support/tickets — user's tickets
- [ ] GET /api/support/tickets/:id — ticket thread
- [ ] POST /api/support/tickets/:id/reply — user reply
- [ ] Admin reply endpoint
- [ ] Auto-close after 7 days of inactivity

**Categories:** General | Refund Request | Cheat Report | Technical Issue | KYC Issue

### 9.2 Flutter UI ⬜
- [ ] Support screen with FAQ accordion
- [ ] Raise ticket form (category, subject, description, screenshot attach)
- [ ] My tickets list with status badges (Open / In Progress / Resolved)
- [ ] Ticket thread / conversation view

---

## PHASE 10 — Admin Panel (Week 11–13)

### 10.1 Backend Admin APIs ⬜

**Module: /modules/admin (all routes protected by adminMiddleware)**
- [ ] User Management: list, search, ban/unban, view full profile, override wallet
- [ ] KYC: list pending, approve/reject (PAN + Aadhaar)
- [ ] Tournament: create, edit, start, cancel, force result
- [ ] Wallet: view all transactions, approve withdrawals, issue refunds
- [ ] Match Monitoring: list live games, view game state, force end
- [ ] Revenue Reports: daily/monthly revenue, fee collected, payouts
- [ ] Cheat Reports: view flagged users, review games, ban

### 10.2 Admin Panel Frontend ⬜

> Recommend: Next.js admin panel (separate web app)

- [ ] Login with admin JWT (separate role)
- [ ] Dashboard: KPIs (DAU, revenue, active games, pending withdrawals)
- [ ] User management table with search + filters
- [ ] KYC verification queue with document viewer
- [ ] Tournament management + bracket editor
- [ ] Wallet / transaction explorer
- [ ] Game replay viewer (board stepping through moves)
- [ ] Support ticket management

---

## PHASE 11 — Anti-Cheat & Security (Week 13–14)

### 11.1 Anti-Engine Detection ⬜
- [ ] Log all moves with server timestamps
- [ ] Track average move time per player per game
- [ ] Flag players whose moves consistently correlate > 95% with Stockfish best moves
- [ ] suspiciousActivityScore field on User
- [ ] Auto-flag for review when score > threshold

### 11.2 Bot & Fraud Detection ⬜
- [ ] Rate limit socket events (no more than 1 move/second)
- [ ] Detect abnormally fast wins in paid matches → auto-hold prize pending review
- [ ] IP rate limiting on auth endpoints
- [ ] Device fingerprinting (prevent multi-account from same device)

### 11.3 Security Hardening ⬜
- [ ] All financial endpoints: HMAC signature verification
- [ ] Razorpay webhook secret validation
- [ ] MongoDB field-level encryption for sensitive data
- [ ] Helmet.js headers (already in use ✅)
- [ ] Rate limiting (already in use ✅)
- [ ] CORS: lock to app bundle ID + admin panel domain
- [ ] Audit log every admin action + wallet transaction

### 11.4 KYC Verification ⬜
- [ ] PAN card number + photo upload (mandatory for withdrawal)
- [ ] Aadhaar number (last 4 digits + photo)
- [ ] Store in encrypted field, only admin can view
- [ ] Manual approval or integrate Surepass / Digilocker API

---

## PHASE 12 — Performance & Production Readiness (Week 14–15)

### 12.1 Backend Performance ⬜
- [ ] Redis caching for leaderboards, user profiles, active games
- [ ] MongoDB indexes on: userId, gameId, createdAt, status
- [ ] Horizontal scaling with socket.io-redis-adapter (already in deps ✅)
- [ ] PM2 cluster mode on production server
- [ ] Health check endpoint GET /health
- [ ] Graceful shutdown handling

### 12.2 Flutter Performance ⬜
- [ ] Lazy-load routes (already via GetX ✅)
- [ ] Image caching (cached_network_image)
- [ ] Avoid rebuilding full widget tree on socket events (use Obx scoping)
- [ ] Release mode build optimizations
- [ ] App size reduction (remove unused assets)

### 12.3 CI/CD Pipeline 🔄
- [ ] GitHub Actions: lint + test on PR
- [ ] Auto-deploy backend to server on push to main
- [ ] Flutter: auto-build APK / AAB on release tag
- [ ] Staging vs Production environment configs

### 12.4 Monitoring & Logging ⬜
- [ ] Winston structured logging (already ✅) → ship to Papertrail or Logtail
- [ ] Sentry error tracking (backend + Flutter)
- [ ] Uptime monitoring (UptimeRobot / Better Uptime)
- [ ] Server metrics via Grafana + Prometheus or Datadog

---

## PHASE 13 — iOS App & Store Deployment (Week 15–16)

### 13.1 iOS Support ⬜
- [ ] Configure Podfile and iOS permissions (notifications, camera for KYC)
- [ ] Test all flows on iOS simulator + real device
- [ ] Handle platform-specific Razorpay UI differences
- [ ] Push notification setup for APNs

### 13.2 Store Submissions ⬜

**Google Play Store:**
- [ ] App bundle (AAB), signing keystore
- [ ] Real Money Gaming policy compliance
- [ ] Age rating: 18+
- [ ] Privacy policy page (mandatory)

**Apple App Store:**
- [ ] Real money gaming category (requires special entitlement from Apple)
- [ ] Submit for App Review with all flows documented
- [ ] In-App Purchase review compliance

---

## Summary Table

| Phase | Feature Area | Est. Time |
|-------|-------------|-----------|
| 1 | Foundation & Auth | 2 weeks |
| 2 | Chess Gameplay Completion | 1.5 weeks |
| 3 | Matchmaking & Contests | 1.5 weeks |
| 4 | Wallet & Payments | 1.5 weeks |
| 5 | ELO & Leaderboards | 1 week |
| 6 | Tournaments | 2 weeks |
| 7 | Notifications (FCM) | 1 week |
| 8 | Social Features | 1 week |
| 9 | Support System | 1 week |
| 10 | Admin Panel | 2 weeks |
| 11 | Anti-Cheat & Security | 1.5 weeks |
| 12 | Performance & DevOps | 1 week |
| 13 | iOS + Store Launch | 1 week |
| **Total** | | **~19 weeks** |

---

## Current Codebase Status

| Module | Backend | Flutter |
|--------|---------|---------|
| Auth (JWT Login/Register) | ✅ | ✅ |
| Socket Connection | 🔄 | 🔄 |
| Matchmaking (1v1 queue) | ✅ | ✅ |
| Chess Game (basic moves) | ✅ | ✅ |
| Chess Clock | ✅ | 🔄 |
| Leaderboard | 🔄 | 🔄 |
| ELO Rating | ⬜ | ⬜ |
| User Profile | 🔄 | ⬜ |
| Wallet | ⬜ | ⬜ |
| Razorpay Payments | ⬜ | ⬜ |
| Tournaments | ⬜ | ⬜ |
| Notifications (FCM) | ⬜ | ⬜ |
| Friends / Social | ⬜ | ⬜ |
| Support Tickets | ⬜ | ⬜ |
| Admin Panel | ⬜ | ⬜ |
| Anti-Cheat | ⬜ | ⬜ |
| KYC Verification | ⬜ | ⬜ |

---

*Last Updated: 2026-07-02*
