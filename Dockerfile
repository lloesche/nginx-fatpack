FROM debian:jessie

MAINTAINER Lukas Loesche "lloesche@fedoraproject.org"

ENV OPENRESTY_VERSION 1.9.7.3
ENV LAME_VERSION 3.99.5
ENV LIBOGG_VERSION 1.3.2
ENV LIBVORBIS_VERSION 1.3.4

# prep
RUN mkdir -p /root/build
RUN apt-get update
RUN apt-get -y upgrade

# runtime requirementes
RUN apt-get -y install \
	ca-certificates \
	fontconfig-config \
	fonts-dejavu-core \
	geoip-database \
	geoip-database-extra \
	gettext-base \
	libalgorithm-c3-perl \
	libarchive-extract-perl \
	libarchive-tar-perl \
	libcgi-fast-perl \
	libcgi-pm-perl \
	libclass-c3-perl \
	libclass-c3-xs-perl \
	libcpan-meta-perl \
	libdata-optlist-perl \
	libdata-section-perl \
	libexpat1 \
	libfcgi-perl \
	libfontconfig1 \
	libfreetype6 \
	libgd3 \
	libgdbm3 \
	libgeoip1 \
	libjbig0 \
	libjpeg62-turbo \
	liblog-message-perl \
	liblog-message-simple-perl \
	libpam0g \
	libparams-util-perl \
	libpcre3 \
	libperl5.20 \
	libpng12-0 \
	libpod-latex-perl \
	libpod-readme-perl \
	libpq5 \
	libregexp-common-perl \
	libsoftware-license-perl \
	libssl1.0.0 \
	libsub-exporter-perl \
	libsub-install-perl \
	libterm-ui-perl \
	libtext-soundex-perl \
	libtext-template-perl \
	libtiff5 \
	libvpx1 \
	libx11-6 \
	libx11-data \
	libxau6 \
	libxcb1 \
	libxdmcp6 \
	libxml2 \
	libxpm4 \
	libxslt1.1 \
	perl \
	perl-base \
	perl-modules \
	rename \
	sgml-base \
	xml-core

# build requirements
RUN apt-get -y install \
	build-essential \
	git \
	libexpat1-dev \
	libgd-dev \
	libgeoip-dev \
	libpam0g-dev \
	libpcre3-dev \
	libperl-dev \
	libpq-dev \
	libssl-dev \
	libxml2-dev \
	libxslt1-dev \
	mercurial \
	wget

WORKDIR /root/build
RUN wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
    tar xzvf openresty-${OPENRESTY_VERSION}.tar.gz
RUN hg clone http://hg.nginx.org/njs/
RUN git clone https://github.com/arut/nginx-rtmp-module.git
RUN git clone https://github.com/stogh/ngx_http_auth_pam_module.git
RUN git clone https://github.com/arut/nginx-dav-ext-module.git
RUN git clone https://github.com/gnosek/nginx-upstream-fair.git
RUN git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git

# build
WORKDIR /root/build/openresty-${OPENRESTY_VERSION}
RUN ./configure \
	--add-module=../nginx-rtmp-module \
	--add-module=../ngx_http_auth_pam_module \
	--add-module=../nginx-dav-ext-module \
	--add-module=../nginx-upstream-fair \
	--prefix=/usr/share \
	--sbin-path=/usr/sbin/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--http-log-path=/var/log/nginx/access.log \
	--error-log-path=/var/log/nginx/error.log \
	--lock-path=/var/lock/nginx.lock \
	--pid-path=/run/nginx.pid \
	--http-client-body-temp-path=/var/lib/nginx/body \
	--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	--http-proxy-temp-path=/var/lib/nginx/proxy \
	--http-scgi-temp-path=/var/lib/nginx/scgi \
	--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
	--user=www-data \
	--group=www-data \
	--with-http_perl_module \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-threads \
	--with-stream \
	--with-stream_ssl_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-http_v2_module \
	--with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
	--with-ld-opt=-Wl,-z,relro \
	--with-ipv6 \
	--with-luajit -j2 \
	--with-debug \
	--with-pcre-jit \
	--with-http_postgres_module \
	--with-http_iconv_module
RUN make
RUN make install

RUN mkdir -p /var/lib/nginx /var/log/nginx
RUN chown www-data:www-data /var/lib/nginx

# log to console by default
# volume mount can override this setting
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log


# build ffmpeg
RUN apt-get -y install autoconf automake cmake libtool nasm yasm
WORKDIR /root/build
RUN hg clone https://bitbucket.org/multicoreware/x265
RUN git clone --depth 1 git://git.videolan.org/x264
RUN git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
RUN git clone git://git.opus-codec.org/opus.git
RUN git clone http://source.ffmpeg.org/git/ffmpeg.git
RUN wget http://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.[[:digit:]]*}/lame-${LAME_VERSION}.tar.gz && \
    tar xzvf lame-${LAME_VERSION}.tar.gz
RUN wget http://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz && \
    tar xzvf libogg-${LIBOGG_VERSION}.tar.gz
RUN wget http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz && \
    tar xzvf libvorbis-${LIBVORBIS_VERSION}.tar.gz
RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git

# x264
WORKDIR /root/build/x264
RUN ./configure --enable-shared --prefix=/usr && \
    make && \
    make install

# x265
WORKDIR /root/build/x265/build/linux
RUN cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr ../../source && \
    make && \
    make install

# fdk-aac
WORKDIR /root/build/fdk-aac
RUN autoreconf -fiv && \
    ./configure --prefix=/usr && \
    make && \
    make install

# lame
WORKDIR /root/build/lame-${LAME_VERSION}
RUN ./configure --prefix=/usr --enable-nasm && \
    make && \
    make install

# opus
WORKDIR /root/build/opus
RUN autoreconf -fiv && \
    ./configure --prefix=/usr && \
    make && \
    make install

# libogg
WORKDIR /root/build/libogg-${LIBOGG_VERSION}
RUN ./configure --prefix=/usr && \
    make && \
    make install

# libvorbis
WORKDIR /root/build/libvorbis-${LIBVORBIS_VERSION}
RUN ./configure --prefix=/usr && \
    make && \
    make install

# libvpx
WORKDIR /root/build/libvpx
RUN ./configure --prefix=/usr --disable-examples && \
    make && \
    make install

# ffmpeg
WORKDIR /root/build/ffmpeg
RUN ./configure --prefix=/usr --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 && \
    make && \
    make install

# cleanup
WORKDIR /root
RUN rm -rf build

RUN apt-get -yf remove --auto-remove \
	build-essential \
	git \
	libexpat1-dev \
	libgd-dev \
	libgeoip-dev \
	libpam0g-dev \
	libpcre3-dev \
	libperl-dev \
	libpq-dev \
	libssl-dev \
	libxml2-dev \
	libxslt1-dev \
	mercurial \
	wget

RUN apt-get -yf remove --auto-remove autoconf automake cmake libtool nasm yasm
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# run
WORKDIR /usr/share/nginx
EXPOSE 80 443 1935
CMD ["nginx", "-g", "daemon off;"]
