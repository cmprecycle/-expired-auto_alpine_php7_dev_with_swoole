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
COPY php.ini /etc/php7/
