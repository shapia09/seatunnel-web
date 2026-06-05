# Final image only - build Maven separately before docker build
FROM openjdk:8-jre-alpine
LABEL org.opencontainers.image.source="https://github.com/shapia09/seatunnel-web"

ENV DOCKER=true
ENV TZ=Asia/Shanghai
ENV SEATUNNEL_WEB_HOME=/opt/app/seatunnel-web

WORKDIR $SEATUNNEL_WEB_HOME

# Copy pre-built distribution (run mvn package first)
ADD seatunnel-web-dist/target/apache-seatunnel-web-*/ $SEATUNNEL_WEB_HOME/

EXPOSE 8080

CMD ["/bin/sh", "/opt/app/seatunnel-web/bin/seatunnel-backend-daemon.sh", "start"]
