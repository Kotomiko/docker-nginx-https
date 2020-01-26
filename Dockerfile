FROM alpine:3.11

LABEL maintainer="kotomi@kotomiko.com"

ARG BUILD_ROOT=/usr/local/nginx
ARG CACHE_ROOT=/var/cache/nginx
ARG NGINX_VERSION=1.16.1
ARG OPENSSL_VERSION=1.1.1d
ARG OPENSSL_SHA256=1e3a91bc1f9dfce01af26026f856e064eab4c8ee0a8f457b5ae30b40b8b711f2

RUN apk add --no-cache --virtual .build-deps \
        git \
        gcc \
        libc-dev \
        make \
        pcre-dev \
        zlib-dev \ 
        perl-dev \
        linux-headers \
    && apk add --no-cache --virtual .nginx-rundeps \
        pcre \
        su-exec \
    && addgroup -g 109 -S nginx \
    && adduser -s /sbin/nologin -G nginx -S -D -H -u 109 nginx\
    && mkdir /var/run/nginx \
    && mkdir /var/log/nginx \
    && mkdir -p ${CACHE_ROOT} \
    && mkdir -p ${BUILD_ROOT} \
    && touch /var/run/nginx/nginx.pid \
    && chown nginx:nginx /var/log/nginx \
    && chown nginx:nginx ${CACHE_ROOT} \
    && chown nginx:nginx /var/run/nginx/nginx.pid \
    && cd ${BUILD_ROOT} \
    && wget -S -O nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && wget -S -O openssl.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && echo "$OPENSSL_SHA256 *openssl.tar.gz" | sha256sum -c - \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init \
    && cd .. \
    && mkdir nginx \
    && mkdir openssl \
    && tar --extract --file nginx.tar.gz --directory ./nginx --strip-components 1 \
    && tar --extract --file openssl.tar.gz --directory ./openssl --strip-components 1 \
    && BUILD_CONFIG="\
        --prefix=/usr/local/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --user=nginx \
        --group=nginx \
        --with-threads \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_gzip_static_module \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=${CACHE_ROOT}/client \
        --http-proxy-temp-path=${CACHE_ROOT}/proxy \
        --http-fastcgi-temp-path=${CACHE_ROOT}/fastcgi \
        --http-uwsgi-temp-path=${CACHE_ROOT}/uwsgi \
        --http-scgi-temp-path=${CACHE_ROOT}/scgi \
        --add-module=${BUILD_ROOT}/ngx_brotli \
        --with-openssl=${BUILD_ROOT}/openssl \
    "\
    && cd nginx \
    && ./configure $BUILD_CONFIG \
    && make \
    && make install \
    && strip /usr/sbin/nginx* \
    && cd .. \
    && rm -rf ${BUILD_ROOT} \
    && apk del .build-deps

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["nginx"]
