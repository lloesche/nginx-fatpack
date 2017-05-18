# nginx-fatpack
nginx/openresty/rtmp/ffmpeg Docker image with lots of modules for video streaming app server

You can `docker run lloesche/nginx-fatpack`. You likely also want to volume mount /etc/nginx with a custom config.
Image uses openresty as base nginx plus several useful modules including rtsp support. Also includes ffmpeg for live transcoding.

Example config
```
rtmp {
	server {
		listen 1935;
		chunk_size 4096;

		application live {
			live on;
			record off;
		}
	}
}
```

Output of nginx -V
```
nginx version: openresty/1.9.7.3
built by gcc 4.9.2 (Debian 4.9.2-10)
built with OpenSSL 1.0.1k 8 Jan 2015
TLS SNI support enabled
configure arguments: --prefix=/usr/share/nginx --with-debug --with-cc-opt='-DNGX_LUA_USE_ASSERT -DNGX_LUA_ABORT_AT_PANIC -O2 -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' --add-module=../ngx_devel_kit-0.2.19 --add-module=../iconv-nginx-module-0.13 --add-module=../echo-nginx-module-0.58 --add-module=../xss-nginx-module-0.05 --add-module=../ngx_coolkit-0.2rc3 --add-module=../set-misc-nginx-module-0.29 --add-module=../form-input-nginx-module-0.11 --add-module=../encrypted-session-nginx-module-0.04 --add-module=../ngx_postgres-1.0rc7 --add-module=../srcache-nginx-module-0.30 --add-module=../ngx_lua-0.10.0 --add-module=../ngx_lua_upstream-0.04 --add-module=../headers-more-nginx-module-0.29 --add-module=../array-var-nginx-module-0.04 --add-module=../memc-nginx-module-0.16 --add-module=../redis2-nginx-module-0.12 --add-module=../redis-nginx-module-0.3.7 --add-module=../rds-json-nginx-module-0.14 --add-module=../rds-csv-nginx-module-0.07 --with-ld-opt='-Wl,-rpath,/usr/share/luajit/lib -Wl,-z,relro' --add-module=/root/build/openresty-1.9.7.3/../nginx-rtmp-module --add-module=/root/build/openresty-1.9.7.3/../ngx_http_auth_pam_module --add-module=/root/build/openresty-1.9.7.3/../nginx-dav-ext-module --add-module=/root/build/openresty-1.9.7.3/../nginx-upstream-fair --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --user=www-data --group=www-data --with-http_perl_module --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-threads --with-stream --with-stream_ssl_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_v2_module --with-ipv6 --with-pcre-jit
```

Automatic build on Docker Hub takes longer than 2h therefor runs into a timeout. Could be avoided by splitting the image up in several independent images. Or I'll just wait for Docker to eventually get faster CPUs/increase the time limit.
