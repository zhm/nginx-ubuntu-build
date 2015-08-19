# Install + modify this package: https://launchpad.net/~nginx/+archive/ubuntu/stable/+packages

if [ -f "/opt/rebuildnginx-extras/nginx-extras_1.8.0-1+trusty1_amd64.deb" ]
then
  exit 0
fi

add-apt-repository ppa:nginx/stable -y

echo "deb-src http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list.d/nginx-stable-trusty.list

apt-get update

rm -rf /opt/httpupload
mkdir /opt/httpupload
cd /opt/httpupload
wget https://github.com/vkholodkov/nginx-upload-module/archive/2.2.zip
unzip 2.2.zip

apt-get install -y dpkg-dev
rm -rf /opt/rebuildnginx-extras
mkdir -p /opt/rebuildnginx-extras
cd /opt/rebuildnginx-extras
apt-get source -y nginx-extras
apt-get build-dep nginx-extras

# Add `--add-module=/opt/httpupload/nginx-upload-module-2.2` to the end of the configure command
# used to build nginx. This could easily be edited by hang, but installation of nginx would then be
# a manual process. This is a somewhat fragile approach, but it will work for the current 1.8.0
# deb package rules.
ruby -e "content = File.read('/opt/rebuildnginx-extras/nginx-1.8.0/debian/rules').gsub('--add-module=\$(MODULESDIR)/ngx_http_substitutions_filter_module', \"--add-module=\$(MODULESDIR)/ngx_http_substitutions_filter_module \\\\\n\\t\\t\\t--add-module=/opt/httpupload/nginx-upload-module-2.2\"); File.open('/opt/rebuildnginx-extras/nginx-1.8.0/debian/rules', 'wb') {|f| f.write(content)}"

cd /opt/rebuildnginx-extras/nginx-1.8.0

apt-get install -y libgd2-noxpm-dev debhelper dh-systemd libgeoip-dev libluajit-5.1-dev libmhash-dev libperl-dev

dpkg-buildpackage -b

cd /opt/rebuildnginx-extras

apt-get remove -y nginx nginx-extras nginx-common

apt-get install -y nginx-common init-system-helpers

dpkg --install nginx-extras_1.8.0-1+trusty1_amd64.deb
