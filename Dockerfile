FROM docker-php-5.3

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive


# Copy files in /root into the image.
COPY /files/ /

# RUN set -ex && \
# 	chmod +x /entrypoint*.sh && \
# 	curl -f --output /tmp/cloudflare-ips-v4 --connect-timeout 30 https://www.cloudflare.com/ips-v4 2> /dev/null && \
#	sleep 3 && \
# 	curl -f --output /tmp/cloudflare-ips-v6 --connect-timeout 30 https://www.cloudflare.com/ips-v6 2> /dev/null && \
# 	ls -lah /tmp/cloudflare* && \
# 	apt-get update -y \
# 	&& apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
# 		cron nginx memcached supervisor \
# 		ssmtp bsd-mailx \
# 		procps \
# 	&& apt-get autoremove

RUN set -ex && \
	chmod +x /entrypoint*.sh && \
	# curl -f --output /tmp/cloudflare-ips-v4 --connect-timeout 30 https://www.cloudflare.com/ips-v4 2> /dev/null && \
	# sleep 3 && \
	# curl -f --output /tmp/cloudflare-ips-v6 --connect-timeout 30 https://www.cloudflare.com/ips-v6 2> /dev/null && \
	# ls -lah /tmp/cloudflare* && \
	apt-get update -y && \
	apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
		#cron nginx memcached supervisor \
		\
		# for sending mail via PHP.
		ssmtp bsd-mailx \
		\
		#gosu sudo \
		\
		# This provides: ps, top, uptime, pkill, watch, etc...
		# Reference: https://packages.ubuntu.com/xenial/amd64/procps/filelist
		procps \
		\
		git \
		\
		libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libxpm-dev libmcrypt-dev imagemagick libmagickwand-dev \
		\
		# Fix: configure: error: utf8_mime2text() has new signature, but U8T_CANONICAL is missing. This should not happen. Check config.log for additional information.
		# Reference: http://www.howtodoityourself.org/fix-error-utf8_mime2text.html
		# Reference: https://packages.ubuntu.com/xenial/libdevel/libc-client2007e-dev
		libkrb5-dev libc-client2007e-dev krb5-multidev libpam0g-dev libssl-dev \
		\
		libpspell-dev librecode-dev libtidy-dev libxslt1-dev libgmp-dev libmemcached-dev zip unzip zlib1g-dev \
	\
	# sendmail setup with SSMTP for mail().
	&& echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
	&& echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini \
  \
	&& docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install zip gmp bcmath gd gettext imap intl mysqli pspell recode tidy xsl \
  \
  #&& docker-php-source extract \
  	&& cd /usr/src/php/ext \
  	\
    && curl -fsSL 'http://pecl.php.net/get/imagick' -o imagick.tar.gz \
    && mkdir -p imagick \
    && tar -xf imagick.tar.gz -C imagick --strip-components=1 \
		&& docker-php-ext-configure imagick --enable-imagick \
		&& docker-php-ext-install imagick \
    && rm -r imagick.tar.gz imagick \
  	\
		&& curl -fsSL http://pecl.php.net/get/memcache -o memcache.tar.gz \
    && mkdir -p memcache \
    && tar -xf memcache.tar.gz -C memcache --strip-components=1 \
		&& docker-php-ext-configure memcache --enable-memcache \
		&& docker-php-ext-install memcache \
    && rm -r memcache.tar.gz memcache \
		# \
		# && git clone https://github.com/websupport-sk/pecl-memcache memcache \
		# && docker-php-ext-configure memcache --enable-memcache \
		# && docker-php-ext-install memcache \
		# && rm -r memcache \
#		\
  #&& docker-php-source delete \
  && true



ENTRYPOINT ["/entrypoint.sh"]
CMD ["startup"]
