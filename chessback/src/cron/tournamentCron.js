const cron = require('node-cron');
const Tournament = require('../models/Tournament');
const User = require('../models/User');
const { sendPushNotification } = require('../config/firebaseAdmin');
const TournamentEngine = require('../services/tournamentEngine');

const initTournamentCron = () => {
  // Run every minute
  cron.schedule('* * * * *', async () => {
    try {
      const now = new Date();
      // Calculate time 15 minutes from now
      const in15Minutes = new Date(now.getTime() + 15 * 60000);

      // Find tournaments starting in <= 15 minutes that haven't sent a reminder
      const upcomingTournaments = await Tournament.find({
        status: 'registration',
        startTime: { $lte: in15Minutes, $gt: now },
        reminderSent: false
      });

      for (const tournament of upcomingTournaments) {
        if (tournament.registeredPlayers && tournament.registeredPlayers.length > 0) {
          // Find all registered users who have fcmTokens
          const users = await User.find({
            userId: { $in: tournament.registeredPlayers },
            'fcmTokens.0': { $exists: true }
          });

          // Extract all fcm tokens
          const fcmTokens = users.flatMap(u => u.fcmTokens || []).filter(Boolean);

          if (fcmTokens.length > 0) {
            await sendPushNotification(
              fcmTokens,
              'Tournament Starting Soon!',
              `Your tournament "${tournament.name}" is starting in less than 15 minutes. Be ready!`,
              { type: 'TOURNAMENT_REMINDER', tournamentId: tournament.tournamentId }
            );
            console.log(`[CRON] Sent reminder for tournament ${tournament.tournamentId} to ${fcmTokens.length} devices.`);
          }
        }

        // Mark reminder as sent so we don't spam them every minute
        tournament.reminderSent = true;
        await tournament.save();
      }

      // Check for tournaments that have reached their start time
      const tournamentsToStart = await Tournament.find({
        status: 'registration',
        startTime: { $lte: now }
      });

      for (const tournament of tournamentsToStart) {
        await TournamentEngine.startTournament(tournament._id);
      }

    } catch (error) {
      console.error('[CRON] Error in tournament reminder cron:', error);
    }
  });

  console.log('Tournament cron jobs initialized.');
};

module.exports = initTournamentCron;
