#!/bin/bash
cat PKGBUILD.* > PKGBUILD
source PKGBUILD
curdir=$PWD
cd $curdir
makepkg -g >> PKGBUILD
vim PKGBUILD
mkaurball
if [ -v AUR_USER ];then
  burp -u $AUR_USER -p $(<~/.aurpass) -c system -C ~/.burpcookies ${pkgname}-${pkgver}-${pkgrel}.src.tar.gz
else
  echo "Don't forget to upload to AUR"
fi
