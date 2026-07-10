const { calculateElo } = require('../src/utils/elo');

describe('ELO Calculation', () => {
  it('should calculate correct ELO for a win', () => {
    const newRating = calculateElo(1200, 1200, 1); // 1 = win
    expect(newRating).toBe(1216); // 1200 + 32 * (1 - 0.5)
  });

  it('should calculate correct ELO for a loss', () => {
    const newRating = calculateElo(1200, 1200, 0); // 0 = loss
    expect(newRating).toBe(1184); // 1200 + 32 * (0 - 0.5)
  });

  it('should calculate correct ELO for a draw', () => {
    const newRating = calculateElo(1200, 1200, 0.5); // 0.5 = draw
    expect(newRating).toBe(1200); // 1200 + 32 * (0.5 - 0.5)
  });

  it('should reward more points for beating a higher rated player', () => {
    const newRating = calculateElo(1200, 1600, 1);
    expect(newRating).toBeGreaterThan(1216);
  });
});
