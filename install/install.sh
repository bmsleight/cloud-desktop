#!/bin/bash

#installation

echo "Set hostane, e.g. cloud-desktop ? "
read HOSTNAME
hostname $HOSTNAME

echo "Password for the user cloud ? "
read PASSWORD_USER

#Enabale Lucidbackports if not already.
apt-get update
apt-get --assume-yes install language-pack-en
apt-get --assume-yes purge sendmail*
apt-get --assume-yes purge apache2*

# Required for basic x11vnc
apt-get --assume-yes install xfdesktop4 xfce4-utils xvfb x11vnc apache2-mpm-prefork python-pexpect imagemagick libapache2-mod-proxy-html


#Packages I like
apt-get --assume-yes install abiword ace-of-penguins anacron audacious audacious-plugins chromium-browser chromium-browser-l10n desktop-file-utils evince file-roller galculator gnome-system-tools gnumeric gpicview jockey-gtk language-selector leafpad logrotate mtpaint osmo pidgin scrot simple-scan software-properties-gtk sylpheed sylpheed-i18n synaptic transmission ttf-liberation ttf-unfonts-core ttf-wqy-microhei unzip update-notifier x11-utils xchat xdg-user-dirs xpad xscreensaver zip 

# Just for chromium-browser
chmod 777 /dev/shm

############################################################
# add_user_cloud and setup_x11vnc
############################################################
cd /tmp/
rm /tmp/setup*
wget http://cloud-desktop.googlecode.com/svn/trunk/install/setup.py
python /tmp/setup.py --password="$PASSWORD_USER" --hostname="$HOSTNAME"

rm /tmp/startvnc.sh
wget http://cloud-desktop.googlecode.com/svn/trunk/install/startvnc.sh
echo "/bin/bash /root/startvnc.sh &" > /etc/rc.local
cp /tmp/startvnc.sh /root/startvnc.sh
echo "/bin/bash /root/startvnc.sh &" > /etc/rc.local

############################################################
#ajaxplorer
############################################################
apt-get --assume-yes install php5 php5-mcrypt libapache2-mod-php5
wget "http://downloads.sourceforge.net/project/ajaxplorer/ajaxplorer/3.1.1/ajaxplorer-core-3.1.1.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fajaxplorer%2F&ts=1292661903&use_mirror=garr" -O ajaxplorer.zip
unzip ajaxplorer.zip -d /var/www/
mv /var/www/ajaxplorer-core-3.1.1 /var/www/file
# username for ajaxplorer is admin, password as asked at start of script. 
# alas this is stored in plain text.
cat /var/www/file/server/conf/conf.php | sed s/"admin"/"$PASSWORD_USER"/ >/tmp/conf.php
mv -f /tmp/conf.php /var/www/file/server/conf/conf.php
mkdir /var/www/file/public
chown www-data.www-data /var/www/file -R

adduser cloud www-data
ln -s /var/www/file/files /home/cloud/Desktop/WebFileManager
wget http://cloud-desktop.googlecode.com/svn-history/trunk/install/index.html -O /var/www/index.html
chown www-data.www-data /var/www/index.html

#

############################################################
# Shell in a box
############################################################
wget "http://shellinabox.googlecode.com/files/shellinabox_2.10-1_i386.deb" -O shellinabox.deb
dpkg -i shellinabox.deb
echo "SHELLINABOX_ARGS=\"\${SHELLINABOX_ARGS} -t --localhost-only\" " >>/etc/default/shellinabox

a2enmod ssl rewrite proxy proxy proxy_html proxy_http headers 

# Make certificates...
# Cheat and sue the x11vnc sertificates.....

# We only want https - We may be using any network. So force https.
echo "<VirtualHost *:80>
<Location / >
         RewriteEngine   on
         RewriteCond     %{SERVER_PORT} ^80$
         RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
</Location>
</VirtualHost>" >/etc/apache2/sites-available/default

wget "http://cloud-desktop.googlecode.com/svn-history/trunk/install/default-ssl" -O /etc/apache2/sites-available/default-ssl
cat /etc/apache2/ports.conf | sed s/443/127.0.0.1:443/ >/tmp/ports.conf
mv -f /tmp/ports.conf /etc/apache2/ports.conf
a2ensite default-ssl


# Now we want everything on https://ip:443
# So we use the wonderful connect_switch to look at the first part of the data
# is it "CONNECT..." if so send it to x11vnc
# if it is not we send to apache...
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | grep -v ::1 | head -n 1 | awk '{print $2}'`

wget "http://www.karlrunge.com/x11vnc/connect_switch" -O /root/connect_switch.sh
chmod +x /root/connect_switch.sh
echo "#!/bin/sh
export CONNECT_SWITCH_LISTEN=$ip:443
export CONNECT_SWITCH_HTTPD=127.0.0.1:443
export CONNECT_SWITCH_ALLOWED=localhost:5900
export CONNECT_SWITCH_LOOP=1
export CONNECT_SWITCH_LOOP=BG

/root/connect_switch" >/root/start_connect_switch.sh
chmod +x /root/start_connect_switch.sh
wget "http://www.karlrunge.com/x11vnc/connect_switch" -O /root/connect_switch
chmod +x /root/connect_switch
/etc/init.d/apache2 restart

############################################################
# Open VPN
############################################################

wget "http://cloud-desktop.googlecode.com/svn-history/trunk/install/debian-openvpn.sh" -O /root/debian-openvpn.sh
/bin/bash /root/debian-openvpn.sh
cp /root/keys.tgz /home/cloud/Desktop/WebFileManager/
chown www-data.www-data /home/cloud/Desktop/WebFileManager/keys.tgz

echo "To start the services running, enter the following command :-"
echo "nohup /bin/bash /root/startvnc.sh &"
echo "... or reboot via the VPS control panel."

