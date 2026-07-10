const calculateElo = (playerRating, opponentRating, score, kFactor = 32) => {
  // score: 1 for win, 0.5 for draw, 0 for loss
  const expectedScore = 1 / (1 + Math.pow(10, (opponentRating - playerRating) / 400));
  const newRating = playerRating + kFactor * (score - expectedScore);
  return Math.round(newRating);
};

module.exports = { calculateElo };
