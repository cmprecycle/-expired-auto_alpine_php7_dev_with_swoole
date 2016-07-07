#FROM cmptech/auto_alpine_php7_dev
FROM alpine:edge

Maintainer Wanjo Chan ( http://github.com/wanjochan/ )

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories
RUN echo "http://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories

RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf && apk update && apk upgrade
#RUN apk update && apk upgrade 

#some dev tools
RUN apk add wget curl vim bash

#build essential
RUN apk add autoconf build-base linux-headers

#some libs (may add/change future...)
RUN apk add \
libjpeg \
gmp-dev \
libaio \
re2c \
bison \
libmcrypt-dev \
freetype-dev \
libxpm-dev \
libwebp-dev \
libjpeg-turbo-dev \
bzip2-dev \
openssl-dev \
krb5-dev \
libxml2-dev \
libaio-dev \
curl-dev

RUN apk add php7
RUN apk add php7-dev
RUN apk add php7-pear
RUN apk add php7-opcache

RUN ln -s /usr/bin/php7 /usr/bin/php \
&& ln -s /usr/bin/php-config7 /usr/bin/php-config \
&& ln -s /usr/bin/phpize7 /usr/bin/phpize

#special patch for alpine linux-kernel have some strange incompatibility
RUN sed -i "s/struct sigaction {/#ifndef __sighandler_t \ntypedef void (*__sighandler_t)(int);\n#endif\nstruct sigaction\n{/g" /usr/include/signal.h
RUN sed -i "s/union {void (*sa_handler)(int)/__sighandler_t sa_handler/g" /usr/include/signal.h

#let pecl use /etc/php/php.ini by find the pecl and patch...
RUN sed -i "s/ -n / /" `which pecl`

#install php-swoole
RUN pecl install swoole

#use own php.ini + extension=swoole.so
#COPY php.ini /etc/php7/
RUN (cat <<PHPINIEOF
max_executionn_time=600
memory_limit=512M
error_reporting=1
display_errors=0
log_errors=1
user_ini.filename=
realpath_cache_size=2M
cgi.check_shebang_line=0

#already there
#zend_extension=opcache.so
opcache.enable_cli=1
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
opcache.use_cwd=1
opcache.max_accelerated_files=100000
opcache.max_wasted_percentage=5
opcache.memory_consumption=128
opcache.consistency_checks=0

extension=swoole.so
PHPINIEOF) > /etc/php7/php.ini
