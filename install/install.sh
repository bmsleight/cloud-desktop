#!/bin/bash

#installation

echo "Password for the user cloud ? "
read PASSWORD_USER

#Enabale Lucidbackports if not already.
apt-get update
apt-get --assume-yes install language-pack-en

apt-get --assume-yes purge sendmail*
apt-get --assume-yes purge apache2*

apt-get --assume-yes install xfdesktop4 xfce4-utils xvfb x11vnc apache2-mpm-prefork python-pexpect imagemagick

#Packages I like
apt-get --assume-yes install abiword ace-of-penguins anacron audacious audacious-plugins chromium-browser chromium-browser-l10n desktop-file-utils evince file-roller galculator gnome-system-tools gnumeric gpicview jockey-gtk language-selector leafpad logrotate mtpaint osmo pidgin scrot simple-scan software-properties-gtk sylpheed sylpheed-i18n synaptic transmission ttf-liberation ttf-ubuntu-font-family ttf-unfonts-core ttf-wqy-microhei unzip update-notifier x11-utils xchat xdg-user-dirs xpad xscreensaver zip 

# Just for chromium-browser
chmod 777 /tmp/shm

cd /tmp/
rm /tmp/setup*
wget http://cloud-desktop.googlecode.com/svn/trunk/install/setup.py
python /tmp/setup.py --password="$PASSWORD_USER" --clear="$PASSWORD_CLEAR"

rm /tmp/startvnc.sh
wget http://cloud-desktop.googlecode.com/svn/trunk/install/startvnc.sh
echo "/bin/bash /root/startvnc.sh &" > /etc/rc.local
cp /tmp/startvnc.sh /root/startvnc.sh
echo "/bin/bash /root/startvnc.sh &" > /etc/rc.local

#wget http://shellinabox.googlecode.com/files/shellinabox_2.10-1_i386.deb -O shellinabox.deb
#echo -n admin | md5sum --text | cut -d\  -f1

#apt-get install php5 libapache2-mod-php5
# wget "http://downloads.sourceforge.net/project/extplorer/extplorer/eXtplorer%202.0.1/eXtplorer_2.0.1.zip?r=http%3A%2F%2Fextplorer.sourceforge.net%2F&ts=1292624569&use_mirror=heanet" -O extplorer.zip
#mkdir /var/www/extplorer
#unzip extplorer.zip -d /var/www/extplorer/
#chown www-data.www-data /var/www/ -R
#chmod 777 /var/www/extplorer/
#chmod 777 /var/www/extplorer/ftp_tmp
#chmod 777 /var/www/extplorer/config
#e=$(echo -n $PASSWORD_USER | md5sum --text | cut -d\  -f1)
#cat /var/www/extplorer/config/.htusers.php | sed s/21232f297a57a5a743894a0e4a801fc3/$e/ >/var/www/extplorer/config/.htusers.php 
#chown www-data.www-data /var/www/extplorer/config/.htusers.php
#chmod 666 /var/www/extplorer/config/.htusers.php

echo "To start the services running, enter the following command :-"
echo "nohup /bin/bash /root/startvnc.sh &"
echo "... or reboot via the VPS control panel."

