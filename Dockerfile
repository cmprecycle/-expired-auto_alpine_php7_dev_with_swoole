FROM cmptech/auto_alpine_php7_dev

#special patch for alpine linux-kernel have some strange incompatibility
RUN sed -i "s/struct sigaction {/#ifndef __sighandler_t \ntypedef void (*__sighandler_t)(int);\n#endif\nstruct sigaction\n{/g" /usr/include/signal.h
RUN sed -i "s/union {void (*sa_handler)(int)/__sighandler_t sa_handler/g" /usr/include/signal.h

#let pecl use /etc/php/php.ini by find the pecl and patch...
RUN sed -i "s/ -n / /" `which pecl`

#install php-swoole
RUN pecl install swoole

#use own php.ini + extension=swoole.so
COPY php.ini /etc/php7/
