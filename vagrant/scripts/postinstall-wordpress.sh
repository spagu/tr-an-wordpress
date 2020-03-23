#!/bin/sh

echo 'Running post-install..'

echo 'Setting up pkg'
if [ ! -f /usr/local/sbin/pkg ]; then
	ASSUME_ALWAYS_YES=yes pkg bootstrap
fi




echo 'Setting up VM Tools..'
#	echo 'ifconfig_em1="inet 10.6.66.42 netmask 255.255.255.0"' >> /etc/rc.conf
echo 'vboxguest_enable="YES"' > /etc/rc.conf.d/vboxguest
echo 'vboxnet_enable="YES"' > /etc/rc.conf.d/vboxnet
echo 'vboxservice_enable="YES"' > /etc/rc.conf.d/vboxservice


echo 'ifconfig_vtnet0_name="em0"' >> /etc/rc.conf
echo 'ifconfig_vtnet1_name="em1"' >> /etc/rc.conf
echo 'ifconfig_em0="DHCP"' >> /etc/rc.conf

echo '# Aliases for jails' >> /etc/rc.conf
echo 'cloned_interfaces="lo1"' >> /etc/rc.conf
echo 'ipv4_addrs_lo1="172.23.0.1/16"' >> /etc/rc.conf

echo
echo 'Clearing tmp at start'
echo 'clear_tmp_enable="YES"' >> /etc/rc.conf

echo 'beastie_disable="YES"' >> /boot/loader.conf
echo 'autoboot_delay="-1"' >> /boot/loader.conf
echo 'virtio_load="YES"' >> /boot/loader.conf
echo 'virtio_pci_load="YES"' >> /boot/loader.conf
echo 'if_vtnet_load="YES"' >> /boot/loader.conf
echo 'vboxdrv_load="YES"' >> /boot/loader.conf
echo 'virtio_balloon_load="YES"' >> /boot/loader.conf
echo 'virtio_blk_load="YES"' >> /boot/loader.conf
echo 'virtio_scsi_load="YES"' >> /boot/loader.conf

echo
echo 'adding repos & removing official'
REPO="/etc/pkg/tradik.conf"
echo '#Tradik config' > ${REPO}
echo 'tradik-ports: {' >> ${REPO}
echo '    url             : "pkg+http://10.0.0.1/",' >> ${REPO}
echo '    enabled         : yes,' >> ${REPO}
echo '    mirror_type     : "srv"' >> ${REPO}
echo '}' >> ${REPO}
echo '' >> ${REPO}
echo 'tradik-sofftware: {' >> ${REPO}
echo '    url             : "pkg+http://10.1.0.3/repo/",' >> ${REPO}
echo '    enabled         : yes,' >> ${REPO}
echo '    mirror_type     : "srv"' >> ${REPO}
echo '}' >> ${REPO}
mv /etc/pkg/FreeBSD.conf /etc/pkg/FreeBSD.conf.disabled

echo
echo 'Instaling OPENVPN'
pkg install -y openvpn
echo 'openvpn_enable="YES"' >> /etc/rc.conf
echo 'openvpn_configfile="/usr/local/etc/openvpn/company.ovpn"' >> /etc/rc.conf
echo 'openvpn_if="tap bridge"' >> /etc/rc.conf
mkdir -p /usr/local/etc/openvpn/
fetch http://10.1.0.3/dev1.tgz -o /usr/local/etc/openvpn/
tar -xzvf /usr/local/etc/openvpn/dev1.tgz -C /usr/local/etc/openvpn/
rm -f /usr/local/etc/openvpn/dev1.tgz
service openvpn start



# install avahi-app
pkg install -y net/avahi-app

# enable avahi-daemon
echo 'dbus_enable="YES"' > /etc/rc.conf.d/dbus
echo 'avahi_daemon_enable="YES"' > /etc/rc.conf.d/avahi_daemon


echo 
echo 'Installing Samba & NFS'
pkg install -y samba42
echo 'samba_server_enable="YES"' >> /etc/rc.conf
echo 'nmbd_enable="YES"' >> /etc/rc.conf
echo 'dumpdev="NO"' >> /etc/rc.conf
echo 'rpcbind_enable="YES"' >> /etc/rc.conf
echo 'nfs_client_enable="YES"' >> /etc/rc.conf
echo '# fsck to protect against unclean shutdowns' >> /etc/rc.conf
echo 'fsck_y_enable="YES"' >> /etc/rc.conf
echo 'rpcbind_enable="YES"' > /etc/rc.conf.d/rpcbind
echo 'nfs_server_enable="YES"' > /etc/rc.conf.d/nfsd


echo 
echo 'Installing respositiories'
pkg install -y git 
pkg install -y subversion
fetch http://10.1.0.3/make.conf -o /etc/make.conf

echo 
echo 'Installing software'
pkg install -y php56
pkg install -y nginx
pkg install -y wordpress
pkg install -y phpmyadmin
pkg install -y MT
pkg install -y mysql56-server
pkg install -y memcached
pkg install -y pecl-memcache
pkg install -y mongodb
pkg install -y php56-gd
pkg install -y imagemagick
pkg install -y mc 
pkg install -y php56-opcache
pkg install -y dos2unix
pkg install -y virtualbox-ose-additions

echo 
echo 'Installing software for build'
pkg install -y node 
pkg install -y npm


echo 
echo 'Installing panel software'
pkg install -y tradik-panel



echo 
echo 'disabling mail'
echo 'sendmail_enable="NONE"' >> /etc/rc.conf
echo 'sendmail_submit_enable="NO"' >> /etc/rc.conf
echo 'sendmail_outbound_enable="NO"' >> /etc/rc.conf
echo 'sendmail_msp_queue_enable="NO"' >> /etc/rc.conf


echo 
echo 'enabling services autostart'
echo 'memcached_enable="YES"' >> /etc/rc.conf
echo 'mysql_enable="YES"' >> /etc/rc.conf
echo 'apache24_enable="YES"' >> /etc/rc.conf
echo 'vsftpd_enable="YES"' >> /etc/rc.conf
echo 'htcacheclean_enable="YES"' >> /etc/rc.conf
echo 'nginx_enable="YES"' >> /etc/rc.conf
echo 'mongodb_enable="YES"' >> /etc/rc.conf
echo 'ntpdate_enable="YES"' >> /etc/rc.conf
echo 'nrpe2_enable="YES"' >> /etc/rc.conf
echo 'php_fpm_enable="YES"' >> /etc/rc.conf
echo 'starman_enable="YES"' >> /etc/rc.conf
echo 'starman_config="/var/www/cgi-bin/mt/mt.psgi"' >> /etc/rc.conf
echo 'starman_flags=" --port 5000"' >> /etc/rc.conf
echo 'sshd_enable="YES"' >> /etc/rc.conf

echo
echo 'Setting up sudo..'
pkg install -y sudo
SUDOETC=/usr/local/etc/sudoers.d/vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > ${SUDOETC}
echo 'Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports' >> ${SUDOETC}
echo 'Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart' >> ${SUDOETC}
echo 'Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports' >> ${SUDOETC}
echo '%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE' >> ${SUDOETC}


echo
echo 'Setting up the vagrant ssh keys'
mkdir ~vagrant/.ssh
chmod 700 ~vagrant/.ssh
echo "ssh-rsa  vagrant insecure public key" > ~vagrant/.ssh/authorized_keys
chown -R vagrant ~vagrant/.ssh
chmod 600 ~vagrant/.ssh/authorized_keys

echo
echo 'Changing roots shell back'
chsh -s tcsh root

# This causes a hang on shutdown that we cannot automatically recover from
#echo 'Patching FreeBSD..'
#freebsd-update fetch install > /dev/null

echo
echo 'Post-install complete.'
