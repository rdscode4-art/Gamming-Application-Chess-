# Load Testing Guide

Load testing a Socket.IO application requires generating high volumes of WebSocket connections and emitting events to simulate concurrent games.

## Recommended Tool: Artillery

Artillery supports Socket.IO natively.

### 1. Installation
```bash
npm install -g artillery
```

### 2. Artillery Configuration (`load_test.yml`)
Create a file named `load_test.yml`:

```yaml
config:
  target: "http://localhost:3000"
  phases:
    - duration: 60
      arrivalRate: 10 # 10 new users per second for 1 minute
  engines:
    socketio: {}

scenarios:
  - name: "Connect and join queue"
    engine: socketio
    flow:
      # In a real scenario, you'd need to mock JWT tokens here
      - emit:
          channel: "join_queue"
      - think: 5 # wait 5 seconds in queue
      - emit:
          channel: "leave_queue"
```

*Note: Since the platform requires JWT authentication for socket connections, your load test script must be adapted to either use a pre-generated list of valid JWT tokens, or hit the `/api/auth/guest` endpoint first to retrieve a token before initiating the socket connection.*

### 3. Execution
```bash
artillery run load_test.yml
```

### 4. Monitoring
While running the test, monitor:
- **Redis Memory/CPU**: `docker stats` or `redis-cli info`
- **Node.js Process**: Watch for event loop lag.
- **MongoDB**: Watch connection pooling limits.
