#!/usr/bin/env bash

# Set the directory to the script's working dir
cd "$(dirname "$0")"

echo "Checking for homebrew and upgrading to lateast"
if [ ! -x /usr/local/bin/brew ]; then
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	brew up
	brew upgrade --all
fi

echo "Unlinking outdated PHP (if found)"
for php in php53 php54 php55 php56; do
	brew list | grep -q $php && brew unlink $php
done

# Install common taps
brew tap homebrew/services
brew tap kabel/php-ext

# Install common formulae
brew install Caskroom/cask/xquartz
brew install openldap
brew install --with-openssl curl
brew install apr-util --with-openldap
brew install gd
brew install git
brew install httpd
brew install imagemagick --with-librsvg --with-webp --with-libwmf --with-liblqr --with-fontconfig --with-ghostscript --with-jp2 --with-x11
brew install jpegoptim
brew install links
brew install media-info
brew install mysql@5.7
brew install node
brew install libmemcached
brew install memcached
brew install php
brew install composer
brew install php-code-sniffer
brew install pngquant
brew install wget
brew install shibboleth-sp
brew install certbot


if [ ! -d /usr/local/etc/httpd ]; then
	echo "Failed to properly install apache"
	exit 1
fi

if [ ! -d /usr/local/etc/php/7.2 ]; then
	echo "Failed to properly install php 7.2"
	exit 1
fi

# Copy patched configuration
echo "Copying common Apache and PHP configuration. It is okay to skip these if you do not want to override your local copy."
cp -ai etc/httpd/* /usr/local/etc/httpd
cp -ai etc/php70/* /usr/local/etc/php/7.2

# Start system daemons
echo "Stopping Apple's Apache..."
sudo /usr/sbin/apachectl stop
echo "Starting Homebrew Memcached on default port..."
sudo brew services restart memcached
echo "Starting Homebrew PHP-FPM on a unix socket..."
sudo brew services restart php
echo "starting Homebrew Apache on default ports..."
sudo brew services restart httpd

echo "✩✩✩✩ IIM OS X Web Stack - Ready ✩✩✩✩"
echo ""
echo "Your web root is at /usr/local/var/www/htdocs. You may want to install a symlink to your local workspace."
