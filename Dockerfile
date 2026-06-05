# Build stage: Maven builds both frontend (via frontend-maven-plugin) and backend
FROM maven:3.8-eclipse-temurin-8 AS builder
WORKDIR /app
COPY . .
RUN mvn package -pl seatunnel-server/seatunnel-app -am -DskipTests -B

# Final image
FROM openjdk:8-jre-alpine
LABEL org.opencontainers.image.source="https://github.com/shapia09/seatunnel-web"

ENV DOCKER=true
ENV TZ=Asia/Shanghai
ENV SEATUNNEL_WEB_HOME=/opt/app/seatunnel-web

WORKDIR $SEATUNNEL_WEB_HOME

# Copy built distribution
COPY --from=builder /app/seatunnel-server/seatunnel-app/target/seatunnel-web/ ./

EXPOSE 8080

CMD ["/bin/sh", "/opt/app/seatunnel-web/bin/seatunnel-backend-daemon.sh", "start"]
