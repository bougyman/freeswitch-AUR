# This builds the FreeSWITCH open source telephone engine
# from the freeswitch git.  It enables the following modules
# not enabled in the standard freeswitch build:
#  * mod_callcenter
#  * mod_xml_curl
# And disables the following standard modules:
#  * mod_dialplan_asterisk
#  * mod_say_ru
#  * mod_spidermonkey
#  * mod_lua
# You can modify this and other options in the BUILD CONFIGURATION section below

# Built using http://wiki.archlinux.org/index.php/VCS_PKGBUILD_Guidelines
# Maintainer: TJ Vanderpoel <tj@rubyists.com>

# BUILD CONFIGURATION BEGINS #

# ENABLE THIS IF YOU WANT ODBC IN THE CORE (uncomment it)
# You must have unixodbc installed or the build will fail

#_odbc=--enable-core-odbc-support

# SET THIS TO GET HIGHER QUALITY SOUNDFILES
# Value can be "hd-", "uhd-", or "cd-" to get 16k, 32k, or 48k sounds.
# By default we only download the 8k sounds. If you only use g711 or
# 8k codecs, leave this as-is

_sounds=""

# ADDED MODULES
# If you don't need/want these modules remove them from _enabled_modules
# You can add any modules here you wish to add, make sure they're not
# in _disabled_modules, though
#
# xml_int/mod_xml_curl - Remote http dialplan lookups/control
# xml_int/mod_xml_cdr - Remote http dialplan lookups/control
# applications/mod_callcenter - Inbound call queueing system
_enabled_modules=(xml_int/mod_xml_curl
                  xml_int/mod_xml_cdr
                  formats/mod_shout
                  applications/mod_callcenter)

# DISABLED MODULES
# Remove from _disabled_modules if you want to build these
#
# languages/mod_spidermonkey - server-side javascript
# languages/mod_lua - server-side lua
# say/mod_say_ru - Russian phrases
# dialplans/mod_dialplan_asterisk - Legacy dialplan
_disabled_modules=(languages/mod_spidermonkey
                   languages/mod_lua
                   say/mod_say_ru
                   dialplans/mod_dialplan_asterisk)

# NOTE: We build --without-python due to Arch defaulting python3 as python. 
# Uncomment the following to attempt building it anyway

#_python=--with-python

# CONCURRENT BOOTSTRAP
# Uncomment this to enable backgrounded concurrent bootstrap operations.
# You will suffer a lot of autotools scroll from this, Fair Warning.

#_concurrent="-j"

# BUILD CONFIGURATION ENDS                     #
#                                              #
# CHANGE ANYTHING BELOW HERE AT YOUR OWN RISK! #
#                                              #

pkgname=freeswitch
pkgver=1.2.0_pre_alpha
pkgrel=7
pkgdesc="Open Source soft switch (telephony engine) built from a specific, stable git commit tag"
arch=('i686' 'x86_64')
url="http://freeswitch.org"
license=('MPL')
depends=("util-linux-ng")
makedepends=('git' 'libjpeg' 'curl')
optdepends=('unixodbc: for odbc support in the core'
            'python: for some contrib scripts')
provides=('freeswitch')
conflicts=('freeswitch')
install=freeswitch.install
source=('freeswitch.conf.d' 'freeswitch.rc.conf' 'README.freeswitch' 'run.freeswitch' 'run_log.freeswitch' 'conf_log.freeswitch')
changelog='ChangeLog'




__gitroot="git://git.freeswitch.org/freeswitch.git"
__gitname="freeswitch"
__gitrev=1a1358a3914200a316978400f9298b273d1248ff


enable_module() {
  _fs_mod=$1
  sed -i -e "s|^#${_fs_mod}|${_fs_mod}|" modules.conf
}

disable_module() {
  _fs_mod=$1
  sed -i -e "s|^${_fs_mod}|#${_fs_mod}|" modules.conf
}

build() {
  cd "$srcdir"
  msg "Connecting to GIT server...."

  if [ -d $__gitname ] ; then
    cd $__gitname
    git fetch origin HEAD
    git checkout $__gitrev
    msg "The local files are updated."
  else
    mkdir $__gitname
    cd $__gitname
    git init
    git remote add origin $__gitroot
    git fetch origin HEAD
    git checkout $__gitrev
  fi

  msg "GIT checkout done or server timeout"
  msg "Starting make..."

  rm -rf "$srcdir/$__gitname-build"
  cp -a "$srcdir/$__gitname" "$srcdir/$__gitname-build"
  cd "$srcdir/$__gitname-build"

  # BUILD BEGINS
  msg "Bootstrapping..."
  ./bootstrap.sh ${_concurrent} > /dev/null
  msg "Bootstrap Complete"

  # MODULE ENABLE/DISABLE
  for _mod in ${_enabled_modules[@]};do
    msg "Enabling $_mod"
    enable_module $_mod
  done

  for _mod in ${_disabled_modules[@]};do
    msg "Disabling $_mod"
    disable_module $_mod
  done

  msg "Module Configuration Complete, Stop Now with Ctrl-C if the above is not correct"
  sleep 5

  # CONFIGURE
  ./configure --prefix=/var/lib/freeswitch ${_python:---without-python} \
    --bindir=/usr/bin --sbindir=/usr/sbin --localstatedir=/var \
    --sysconfdir=/etc/freeswitch --datarootdir=/usr/share \
    --libexecdir=/usr/lib/freeswitch --libdir=/usr/lib/freeswitch \
    --includedir=/usr/include/freeswitch ${_odbc} \
    --with-recordingsdir=/var/spool/freeswitch/recordings \
    --with-dbdir=/var/spool/freeswitch/db \
    --with-pkgconfigdir=/usr/lib/pkgconfig \
    --with-logfiledir=/var/log/freeswitch \
    --with-modinstdir=/usr/lib/freeswitch/mod \
    --with-rundir=/run/freeswitch

  # COMPILE
  make
}

enable_mod_xml() {
  _fs_mod=$(basename $1)

  if [ "x$(grep $_fs_mod $pkgdir/etc/freeswitch/autoload_configs/modules.conf.xml)" == "x" ];then
    msg "Adding missing module ${_fs_mod} to modules.conf.xml"
    sed -i -e "s|^\(\s*</modules>\)|\t\t<\!-- added by archlinux package -->\n\t\t<load module=\"${_fs_mod}\"/>\n\1|" \
      "$pkgdir/etc/freeswitch/autoload_configs/modules.conf.xml"
  else
    msg "Enabling module ${_fs_mod} in modules.conf.xml"
    sed -i -e "s|^\(\s*\)<\!--\s*\(<load module=\"${_fs_mod}\"/>\)\s*-->|\1\2|" \
      "$pkgdir/etc/freeswitch/autoload_configs/modules.conf.xml"
  fi

}

disable_mod_xml() {
  _fs_mod=$(basename $1)
  msg "Disabling module ${_fs_mod} in modules.conf.xml"
  sed -i -e "s|^\(\s*\)\(<load module=\"${_fs_mod}\"/>\)|\1<\!-- \2 -->|" \
    "$pkgdir/etc/freeswitch/autoload_configs/modules.conf.xml"
}

package() {
  cd "$srcdir/$__gitname-build"
  make DESTDIR="$pkgdir/" install
  make DESTDIR="$pkgdir/" ${_sounds}moh-install
  make DESTDIR="$pkgdir/" ${_sounds}sounds-install

  cd "$pkgdir" # MUY IMPORTANT, $PWD is $pkgdir from here on out
  # Mangle freeswitch's installed dirs into a more compliant structure,
  # leaving symlinks in their place so freeswitch doesn't notice.
  ln -s /var/log/freeswitch var/lib/freeswitch/log
  ln -s /var/spool/freeswitch/db var/lib/freeswitch/db
  ln -s /var/spool/freeswitch/recordings var/lib/freeswitch/recordings
  install -D -m 0755 -d var/spool/freeswitch/storage && \
    ln -s /var/spool/freeswitch/storage var/lib/freeswitch/storage
  rm usr/lib/freeswitch/mod/*.la 2>/dev/null|| true
  rm usr/lib/freeswitch/*.la 2>/dev/null || true
  ln -s /usr/lib/freeswitch/mod var/lib/freeswitch/mod
  install -D "$srcdir/freeswitch.rc.conf" etc/rc.d/freeswitch
  install -D -m 0644 "$srcdir/freeswitch.conf.d" etc/conf.d/freeswitch
  install -D -m 0644 "$srcdir/README.freeswitch" usr/share/doc/freeswitch/README
  cp -a "$srcdir/${__gitname}-build/docs" usr/share/doc/freeswitch
  install -D -m 0755 -d usr/share/doc/freeswitch/support-d
  cp -a "$srcdir/${__gitname}-build/support-d" usr/share/doc/freeswitch/
  install -D -m 0755 -d usr/share/doc/freeswitch/scripts
  cp -a "$srcdir/${__gitname}-build/scripts" usr/share/doc/freeswitch/
  # Copy upstream confs 
  install -D -m 0755 -d usr/share/doc/freeswitch/examples/conf.default
  install -D -m 0755 -d usr/share/doc/freeswitch/examples/conf.archlinux
  ln -s /etc/freeswitch var/lib/freeswitch/conf
  cp -a etc/freeswitch/* usr/share/doc/freeswitch/examples/conf.default/

  for _mod in ${_enabled_modules[@]};do
    enable_mod_xml $_mod
  done

  for _mod in ${_disabled_modules[@]};do
    disable_mod_xml $_mod
  done

  mv etc/freeswitch/* usr/share/doc/freeswitch/examples/conf.archlinux/
  rmdir etc/freeswitch
  install -D -m0755 -d usr/share/freeswitch/conf
  install -D -m 0755 "$srcdir/run.freeswitch" etc/sv/freeswitch/run
  install -D -m 0755 "$srcdir/run_log.freeswitch" etc/sv/freeswitch/log/run
  install -D -m 0644 "$srcdir/conf_log.freeswitch" etc/sv/freeswitch/log/conf
} 
md5sums=('f674b302edeb1895bbefcaf7bb8510ca'
         'c83b9f557a3ad362a51b48785aa00f44'
         'bfa0c6c70c8173bc78fd228bd42a98ef'
         '1fc676c6eba5c38af6f77fd3e12a409b'
         'e9f0bdde366bca6fd29a9202818f3591'
         'e6411d793501c29ec4afd6d54018de1b')
