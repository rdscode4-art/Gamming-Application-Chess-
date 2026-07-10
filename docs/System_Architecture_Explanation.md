# System Architecture Explanation - Production Multiplayer Chess Platform

## 1. High-Level Overview
This platform is designed to emulate top-tier chess servers like Chess.com or Lichess. It focuses on **horizontal scalability**, **strict server authority**, and **resilience against network instability**. 

## 1. Backend Architecture (Node.js + Express)
The backend utilizes a **Layered Architecture**:
- **Controllers / Socket Handlers**: Receive input (REST or Socket events), validate payloads using schemas (Zod/Joi), and pass data to the Service layer.
- **Services**: Contain the core business logic (Matchmaking algorithms, ELO calculations, Clock management).
- **Repositories**: Handle all direct data access logic to abstract away MongoDB and Redis specifics.
- **Models**: Mongoose schemas defining the data structure.

### Server Authority
The backend is the sole source of truth. The client (Flutter) is merely a "dumb terminal" that renders state and forwards user intentions. 
- The `chess.js` engine runs on the backend to validate all moves.
- **Chess Clocks** run on the backend using `setInterval` or Redis expiration events, broadcasting the remaining time periodically.

## 2. Infrastructure & State Management
### Redis (In-Memory Data Store & Pub/Sub)
Crucial for horizontal scaling.
- **Socket.IO Redis Adapter**: If the backend is scaled to multiple instances behind a load balancer, Redis ensures that a socket event emitted from Node A reaches a user connected to Node B.
- **Matchmaking Queue**: An atomic Redis List/Set.
- **Active Game State**: Real-time game state (FEN, timers) is cached in Redis for instantaneous reads/writes, only committing to MongoDB upon game completion or significant milestones.
- **Mutex Locks**: When matching players, Redis Distributed Locks (Redlock pattern) prevent race conditions where the same player might be assigned to two different games.

### MongoDB (Persistent Storage)
- Stores user profiles, ELO ratings, match histories, and comprehensive move lists.

## 3. Disconnect & Reconnect Strategy
- When a socket drops, the backend marks the player as `disconnected` in Redis and pauses their clock. 
- A 60-second TTL (Time-To-Live) countdown starts.
- If the user provides a valid `reconnectToken` before the TTL expires, the clock resumes and the frontend receives the latest FEN and timers.
- If the TTL expires, a background job (or Redis Key-Space Notification) triggers a forfeiture, awarding the opponent the win.

## 4. Frontend Architecture (Flutter + GetX)
The frontend utilizes **Feature-First + Clean Architecture**:
- **Presentation**: UI widgets, screens, and GetX Controllers.
- **Domain**: Entities and UseCases (e.g., `MakeMoveUseCase`).
- **Data**: Repositories implementing interfaces defined in the Domain layer, handling API calls (Dio) and Socket.IO emissions.

This decouples the UI from the network logic, making it highly testable and maintainable.

## 5. Security Strategy
- **JWT Authentication**: Sockets are rejected if the handshake lacks a valid JWT.
- **Rate Limiting**: Throttles rapid, spammy socket emissions or API requests.
- **CORS & Helmet**: Protects against common web vulnerabilities.
