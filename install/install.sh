#!/bin/bash

#installation

echo "Password for the user cloud ? "
read PASSWORD_USER

apt-get update
apt-get --assume-yes install language-pack-en

apt-get --assume-yes purge sendmail*
apt-get --assume-yes purge apache2*

apt-get --assume-yes install xfdesktop4 xfce4-utils xvfb x11vnc apache2-mpm-prefork python-pexpect imagemagick

apt-get --assume-yes install abiword ace-of-penguins anacron audacious audacious-plugins chromium-browser chromium-browser-l10n desktop-file-utils evince file-roller galculator gecko-mediaplayer gnome-mplayer gnome-system-tools gnumeric gpicview icedtea-plugin jockey-gtk language-selector leafpad logrotate mtpaint osmo pidgin scrot simple-scan software-properties-gtk sylpheed sylpheed-i18n synaptic transmission ttf-liberation ttf-ubuntu-font-family ttf-unfonts-core ttf-wqy-microhei ubuntu-extras-keyring unzip update-notifier x11-utils xchat xdg-user-dirs xpad xscreensaver zip 


cd /tmp/
rm /tmp/setup*
wget http://cloud-desktop.googlecode.com/svn/trunk/install/setup.py
python /tmp/setup.py --password="$PASSWORD_USER" --clear="$PASSWORD_CLEAR"

rm /tmp/startvnc.sh
wget http://cloud-desktop.googlecode.com/svn/trunk/install/startvnc.sh
echo "/bin/bash /root/startvnc.sh &" > /etc/rc.local
cp /tmp/startvnc.sh /root/startvnc.sh
echo "/bin/bash /root/startvnc.sh &" > /etc/rc.local

echo "To start the services running, enter the following command :-"
echo "nohup /bin/bash /root/startvnc.sh &"
echo "... or reboot via the VPS control panel."

