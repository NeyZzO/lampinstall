#!/bin/bash

#set -e


if [ "$EUID" -ne 0 ]; then
	echo -e "\033[0;31mCe script doit être executé avec sudo! \033[0m"	
	exit 1
fi
# On met d'abord le système à jour
echo -e "\033[0;36m[1/6] -> Mise à jour du système... \033[0m"
apt update -y

# On installe Apache, Mariadb et Php
echo -e "\033[0;36m[2/6] -> Installation des modules necéssaires... \033[0m"
apt install apache2 mariadb-server mariadb-client php php-cli php-fpm php-mbstring php-zip php-gd php-json php-xml php-curl php-mysqli php-pdo php-bz2 -y

export PHPVERS=`php -v | grep -E "^[Pp][Hh][Pp] [0-9]+\.[0-9]+\.[0-9]+" | cut -d " " -f 2`
export PHPVERSMINMAJ=`echo $PHPVERS | cut -d '.' -f 1,2`

systemctl enable --now apache2
systemctl enable --now mariadb

# Activation des modules php
a2enmod php${PHPVERSMINMAJ}
a2enconf php${PHPVERSMINMAJ}-fpm
a2enmod proxy_fcgi setenvif

phpenmod mysqli
phpenmod bz2
										
systemctl restart apache2
echo -e "\033[0;36m[2/6]-> Modules necéssaires installés \033[0m"

# Installation de phpMyAdmin
TEMPDIR=/var/www/temp
mkdir $TEMPDIR -p 2>/dev/null
INSTALLDIR=/var/www/html
mkdir $INSTALLDIR -p 2>/dev/null

echo -e "\033[0;36m[3/6] -> Installation de phpMyAdmin \033[0m"
wget "https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip" -O $TEMPDIR/pma.zip
echo -e "\033[0;36m[3.1/6] Extraction de phpMyAdmin \033[0m"
unzip -q $TEMPDIR/pma.zip -d $TEMPDIR
echo -e "\033[0;36m[3.1/6] Exctraction phpMyAdmin OK \033[0m"

PMA=`ls $TEMPDIR | grep -E "^phpMyAdmin-[0-9]+.[0-9]+.[0-9]+-.*\$"`
mv $TEMPDIR/$PMA $INSTALLDIR/pma
echo -e "\033[0;36m[3/6] -> phpMyAdmin a été installé \033[0m"
rm -r $TEMPDIR

# On créé l'user admin:admin dans mysql
echo -e "\033[0;36m[4/6] -> Ajout de l'utilisateur admin:admin dans mariadb \033[0m"
wget -qO- https://raw.githubusercontent.com/NeyZzO/lampinstall/refs/heads/master/createadmin.sql | mariadb -u root 
echo -e "\033[0;36m[4/6] -> Utilisateur admin:admin ajouté \033[0m"

# On met la configuration de pma dans pma.
echo -e "\033[0;36m[5/6] -> Configuration de phpMyAdmin \033[0m"
wget https://raw.githubusercontent.com/NeyZzO/lampinstall/refs/heads/master/config.inc.php -O $INSTALLDIR/pma/config.inc.php
echo -e "\033[0;36m[5/6] -> Configuration ok \033[0m"

# On ajoute l'icon sur le bureau et dans le menu windows
echo -e "\033[0;36m[6/6] -> Ajout de phpMyAdmin sur le bureau \033[0m"
wget https://raw.githubusercontent.com/NeyZzO/lampinstall/refs/heads/master/pma.desktop -O /usr/share/applications/pma.desktop
cp /usr/share/applications/pma.desktop	/home/*/Bureau
echo -e "\033[0;36m[6/6]-> Terminé \033[0m"

echo -e "\033[0;32mInstallation terminée: LAMP a été installé \033[0m"																																																																												
