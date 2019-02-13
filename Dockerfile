FROM wuyumin/base

ARG NGINX_VERSION=1.14.2
ARG FANCYINDEX_VERSION=0.4.3

RUN apk update && apk upgrade \
  && apk add gcc libc-dev make pcre-dev zlib-dev openssl-dev \
  && rm -rf /var/cache/apk/* /tmp/* \
  && mkdir -p /data/website \
  && addgroup -S www \
  && adduser -D -S -h /data/website -s /sbin/nologin -G www www \
  && chown -R www:www /data/website \
  && wget https://github.com/aperezdc/ngx-fancyindex/archive/v${FANCYINDEX_VERSION}.tar.gz -O ngx-fancyindex.tar.gz \
  && tar zxf ngx-fancyindex.tar.gz \
  && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION} \
  && ./configure --user=www --group=www --without-http_memcached_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
  --add-module=../ngx-fancyindex-${FANCYINDEX_VERSION} \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && sed -i 's/\/\$nginx_version//g' /usr/local/nginx/conf/fastcgi_params \
  && sed -i 's/\/\$nginx_version//g' /usr/local/nginx/conf/fastcgi.conf \
  && cd ../ \
  && rm ngx-fancyindex.tar.gz \
  && rm -rf ngx-fancyindex-${FANCYINDEX_VERSION} \
  && rm nginx-${NGINX_VERSION}.tar.gz \
  && rm -rf nginx-${NGINX_VERSION}

ENV PATH=$PATH:/usr/local/nginx/sbin/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

# --add-module=xxx
# --add-dynamic-module=xxx (load_module ../modules/xxx.so;)
# --with-http_geoip_module=dynamic

# /usr/local/nginx/conf/
# /usr/local/nginx/conf/nginx.conf
# /usr/local/nginx/modules/
# /data/website/
