#!/bin/bash

#set -e


if [ "$EUID" -ne 0 ]; then
	echo -e "\033[0;31mCe script doit être executé avec sudo! \033[0m"	
	exit 1
fi
# On met d'abord le système à jour
echo -e "\033[0;36m-> Mise à jour du système... \033[0m"
apt update -y

# On installe Apache, Mariadb et Php
echo -e "\033[0;36m-> Installation des modules necéssaires... \033[0m"
# apt-get update -y
apt install apache2 mariadb-server mariadb-client php php-cli php-fpm php-mbstring php-zip php-gd php-json php-xml php-curl php-mysqli php-pdo --fix-missing

export PHPVERS=`php -v | grep -E "^[Pp][Hh][Pp] [0-9]+\.[0-9]+\.[0-9]+" | cut -d " " -f 2`
export PHPVERSMINMAJ=`echo $PHPVERS | cut -d '.' -f 1,2`

systemctl enable --now apache2
systemctl enable --now mariadb

# Activation des modules php
a2enmod php${PHPVERSMINMAJ}
a2enconf php${PHPVERSMINMAJ}-fpm
a2enmod proxy_fcgi setenvif

phpenconf mysqli
										
systemctl restart apache2
echo -e "\033[0;36m-> Modules necéssaires installés \033[0m"

# Installation de phpMyAdmin
export TEMPDIR=/var/www/temp
mkdir $TEMPDIR -p 2>/dev/null
export INSTALLDIR=/var/www/html
mkdir $INSTALLDIR -p 2>/dev/null

echo -e "\033[0;36m-> Installation de phpMyAdmin \033[0m"
wget "https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip" -O $TEMPDIR/pma.zip
unzip $TEMPDIR/pma.zip -d $TEMPDIR
export PMA=`ls $TEMPDIR | grep -E "^phpMyAdmin-[0-9]+.[0-9]+.[0-9]+-.*\$"`

mv $TEMPDIR/$PMA $INSTALLDIR/pma
echo -e "\033[0;36m-> phpMyAdmin a été installé \033[0m"
rm -r $TEMPDIR

# On récupère la config de pma sur github:


echo -e "\033[0;32mInstallation terminée: LAMP a été installé \033[0m"																																																																												
