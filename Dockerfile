# alpine:3.9
FROM alpine@sha256:769fddc7cc2f0a1c35abb2f91432e8beecf83916c421420e6a6da9f8975464b6

USER root

RUN addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

RUN ["apk", "add", "--no-cache", "nginx", "nginx-mod-stream"]

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /app && mkdir /etc/nginx/tcpconf.d && chown -R nginx:nginx /etc/nginx
ADD src/docker-startup.sh /app
ADD src/files/authorized_ip /etc/nginx/
ADD src/files/tcp.stream /etc/nginx/tcpconf.d
COPY src/files/nginx_conf /etc/nginx/nginx.conf

EXPOSE 443

WORKDIR /app

CMD ./docker-startup.sh
