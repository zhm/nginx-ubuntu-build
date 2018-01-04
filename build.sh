# Install + modify this package: https://launchpad.net/~nginx/+archive/ubuntu/stable/+packages

NGINX_VERSION="1.12.1"

if [ -f "/opt/rebuildnginx-extras/nginx-extras_$NGINX_VERSION-0+trusty0_amd64.deb" ]
then
  exit 0
fi

add-apt-repository ppa:nginx/stable -y

echo "deb-src http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list.d/nginx-stable-trusty.list

apt-get update

rm -rf /opt/httpupload
mkdir /opt/httpupload
cd /opt/httpupload
wget https://github.com/zhm/nginx-upload-module/archive/master.zip
unzip master.zip

apt-get install -y dpkg-dev
rm -rf /opt/rebuildnginx-extras
mkdir -p /opt/rebuildnginx-extras
cd /opt/rebuildnginx-extras
apt-get source -y nginx-extras
apt-get build-dep nginx-extras

# Add `--add-module=/opt/httpupload/nginx-upload-module-master` to the end of the configure command
# used to build nginx. This could easily be edited by hang, but installation of nginx would then be
# a manual process. This is a somewhat fragile approach, but it will work for the current 1.8.0
# deb package rules.
ruby -e "content = File.read('/opt/rebuildnginx-extras/nginx-$NGINX_VERSION/debian/rules').gsub('--add-dynamic-module=\$(MODULESDIR)/ngx_http_substitutions_filter_module', \"--add-dynamic-module=\$(MODULESDIR)/ngx_http_substitutions_filter_module \\\\\n\\t\\t\\t--add-module=/opt/httpupload/nginx-upload-module-master\"); File.open('/opt/rebuildnginx-extras/nginx-$NGINX_VERSION/debian/rules', 'wb') {|f| f.write(content)}"

cd /opt/rebuildnginx-extras/nginx-$NGINX_VERSION

apt-get install -y libgd2-noxpm-dev debhelper dh-systemd libgeoip-dev libluajit-5.1-dev libmhash-dev libperl-dev

dpkg-buildpackage -b

cd /opt/rebuildnginx-extras

apt-get remove -y nginx nginx-extras nginx-common

apt-get install -y init-system-helpers
apt-get install -y nginx-common=$NGINX_VERSION-0*

sudo dpkg --install \
  nginx-extras_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-auth-pam_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-cache-purge_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-dav-ext_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-echo_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-fancyindex_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-geoip_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-headers-more-filter_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-image-filter_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-lua_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-ndk_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-perl_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-subs-filter_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-uploadprogress_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-upstream-fair_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-http-xslt-filter_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-mail_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-nchan_$NGINX_VERSION-0+trusty0_amd64.deb \
  libnginx-mod-stream_$NGINX_VERSION-0+trusty0_amd64.deb

mkdir -p $NGINX_VERSION
cp nginx-extras_$NGINX_VERSION-0+trusty0_amd64.deb $NGINX_VERSION
cp libnginx-mod-* $NGINX_VERSION

cd $NGINX_VERSION
tar -zcvf ../nginx-$NGINX_VERSION.tar.gz .
