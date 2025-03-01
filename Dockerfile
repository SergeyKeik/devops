FROM alpine:latest as builder

RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    wget

ENV NGINX_VERSION=1.23.2

WORKDIR /usr/src

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz

WORKDIR /usr/src/nginx-${NGINX_VERSION}

RUN ./configure --prefix=/usr/local/nginx \
                --with-http_ssl_module \
                --with-http_v2_module \
                --with-http_realip_module \
                --with-http_gzip_static_module \
    && make && make install
FROM alpine:latest
RUN apk add --no-cache pcre zlib openssl
COPY --from=builder /usr/local/nginx /usr/local/nginx
EXPOSE 8080
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
