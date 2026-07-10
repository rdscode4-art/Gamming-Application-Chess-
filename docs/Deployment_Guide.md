# Deployment Guide

## Prerequisites
- A Linux server (Ubuntu 22.04 recommended)
- Docker and Docker Compose installed
- A domain name (optional but recommended for SSL)

## Steps to Deploy

### 1. Clone the repository
```bash
git clone https://github.com/your-org/chess_platform.git
cd chess_platform
```

### 2. Configure Environment Variables
Edit `backend_node/.env` with your production secrets.
- Change `JWT_SECRET` to a strong random string.
- Set `CLIENT_URL` to your production frontend domain (e.g., `https://play.mychessapp.com`).
- Keep `MONGODB_URI` and `REDIS_URL` as defined in `docker-compose.yml` unless using managed databases (like AWS RDS or ElastiCache).

### 3. Spin up the cluster
Navigate to the docker folder:
```bash
cd docker
docker-compose up -d --build
```

### 4. Reverse Proxy (Nginx)
To expose port 3000 safely, use Nginx:
```nginx
server {
    listen 80;
    server_name api.mychessapp.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
```

### 5. Horizontal Scaling
If you need more Node.js instances to handle load:
```bash
docker-compose up -d --scale backend=3
```
Because we configured the `@socket.io/redis-adapter`, connections spanning across the 3 backend nodes will seamlessly communicate through Redis Pub/Sub. Ensure Nginx is configured with `ip_hash` for sticky sessions if polling is used, though WebSockets inherently maintain persistent connections.
