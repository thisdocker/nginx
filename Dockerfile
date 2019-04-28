FROM wuyumin/base

LABEL maintainer="Yumin Wu"

ARG NGINX_VERSION=1.16.0
ARG FANCYINDEX_VERSION=0.4.3

RUN apk update && apk upgrade \
  && apk add gcc libc-dev make pcre-dev zlib-dev openssl-dev \
  && rm -rf /var/cache/apk/* /tmp/* \
  && mkdir -p /data/local/src \
  && mkdir -p /data/website \
  && addgroup -S www \
  && adduser -D -S -h /data/website -s /sbin/nologin -G www www \
  && chown -R www:www /data/website \
  && cd /data/local/src \
  && wget https://github.com/aperezdc/ngx-fancyindex/archive/v${FANCYINDEX_VERSION}.tar.gz -O ngx-fancyindex.tar.gz \
  && tar zxf ngx-fancyindex.tar.gz \
  && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION} \
  && ./configure --user=www --group=www --without-http_memcached_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
  --add-module=/data/local/src/ngx-fancyindex-${FANCYINDEX_VERSION} \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  # && sed -i '34a \ \ \ \ server_tokens off;\n' /usr/local/nginx/conf/nginx.conf \
  && sed -i 's/#gzip  on;/#gzip  on;\n\n\ \ \ \ server_tokens off;/g' /usr/local/nginx/conf/nginx.conf \
  && sed -i 's/\/\$nginx_version//g' /usr/local/nginx/conf/fastcgi_params \
  && sed -i 's/\/\$nginx_version//g' /usr/local/nginx/conf/fastcgi.conf \
  && rm -rf /data/local/src

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
