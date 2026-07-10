const { Chess } = require('chess.js');

const chess = new Chess();
const moves = [
  {"from":"e2","to":"e4"},
  {"from":"e7","to":"e6"},
  {"from":"f2","to":"f4"},
  {"from":"f7","to":"f6"},
  {"from":"g2","to":"g4"},
  {"from":"g7","to":"g6"},
  {"from":"d2","to":"d4"},
  {"from":"d7","to":"d6"},
  {"from":"c2","to":"c4"},
  {"from":"c7","to":"c6"},
  {"from":"e4","to":"e5"},
  {"from":"b7","to":"b6"},
  {"from":"f4","to":"f5"},
  {"from":"h7","to":"h6"},
  {"from":"e5","to":"f6"},
  {"from":"a7","to":"a6"},
  {"from":"f5","to":"e6"},
  {"from":"d8","to":"d7"},
  {"from":"e6","to":"d7"},
  {"from":"c8","to":"d7"},
  {"from":"f6","to":"f7"},
  {"from":"e8","to":"f7"},
  {"from":"d4","to":"d5"},
  {"from":"c6","to":"c5"},
  {"from":"h2","to":"h4"},
  {"from":"b6","to":"b5"},
  {"from":"c4","to":"b5"},
  {"from":"g6","to":"g5"},
  {"from":"h4","to":"g5"},
  {"from":"f7","to":"g7"},
  {"from":"g5","to":"h6"},
  {"from":"g7","to":"f6"},
  {"from":"g4","to":"g5"},
  {"from":"f6","to":"f5"},
  {"from":"f1","to":"h3"},
  {"from":"f5","to":"e5"}
];

moves.forEach(m => {
  const move = chess.move(m);
  if (!move) console.log('INVALID MOVE:', m);
});

console.log('Game over?', chess.isGameOver());
console.log('Checkmate?', chess.isCheckmate());
console.log('Stalemate?', chess.isStalemate());
console.log('Draw?', chess.isDraw());
console.log('Insufficient material?', chess.isInsufficientMaterial());
console.log('Threefold repetition?', chess.isThreefoldRepetition());
console.log(chess.ascii());
