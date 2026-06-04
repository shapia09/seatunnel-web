# Build stage (Maven CI profile builds both frontend and backend)
FROM maven:3.8-eclipse-temurin-8 AS builder
WORKDIR /app
COPY . .
RUN mvn package -pl seatunnel-web-dist -am -DskipTests -B

# Final image
FROM eclipse-temurin:8-jre-noble
LABEL org.opencontainers.image.source="https://github.com/shapia09/seatunnel-web"

# Install Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/seatunnel-web

# Copy distribution (includes ui/, libs/, conf/, bin/, datasource/)
COPY --from=builder /app/seatunnel-web-dist/target/apache-seatunnel-web-*-seatunnel-web/ ./

# Nginx config: serve /ui/ static, proxy API to backend
RUN cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80;
    server_name _;

    location /ui/ {
        alias /opt/seatunnel-web/ui/;
        try_files $uri $uri/ /ui/index.html;
    }

    location /seatunnel/api/ {
        proxy_pass http://127.0.0.1:8801/seatunnel/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

# Startup script
RUN cat > /opt/seatunnel-web/start.sh <<'STARTUP'
#!/bin/bash
nginx -g "daemon off;" &
exec java -cp "libs/*:conf" org.apache.seatunnel.web.SeatunnelApplication
STARTUP
RUN chmod +x /opt/seatunnel-web/start.sh

EXPOSE 80 8801

CMD ["/opt/seatunnel-web/start.sh"]
