# Build stage: Maven builds both frontend (via frontend-maven-plugin) and backend
FROM maven:3.8-eclipse-temurin-8 AS builder
WORKDIR /app
COPY . .
RUN mvn package -pl seatunnel-web-dist -am -DskipTests -B

# Final image
FROM registry.cn-hangzhou.aliyuncs.com/inrgihc/openjdk:8-jre-alpine
LABEL org.opencontainers.image.source="https://github.com/shapia09/seatunnel-web"

ENV DOCKER=true
ENV TZ=Asia/Shanghai
ENV SEATUNNEL_WEB_HOME=/opt/app/seatunnel-web

WORKDIR $SEATUNNEL_WEB_HOME

# Copy and extract distribution
COPY --from=builder /app/seatunnel-web-dist/target/apache-seatunnel-web-*.tar.gz /tmp/
RUN tar -xzf /tmp/apache-seatunnel-web-*.tar.gz --strip-components=1 -C $SEATUNNEL_WEB_HOME/ && \
    rm /tmp/apache-seatunnel-web-*.tar.gz

EXPOSE 8080

ENTRYPOINT ["sh", "bin/seatunnel-backend-daemon.sh", "start"]
