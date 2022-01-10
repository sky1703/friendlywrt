#!/bin/sh
# THIS SCIPRT ONLY RUN ONCE. Base on /etc/firstboot_${board}
# /etc/init.d/fa-init

TAG=friendlyelec
logger "${TAG}: /root/setup.sh running"

VENDOR=$(cat /tmp/sysinfo/board_name | cut -d , -f1)
BOARD=$(cat /tmp/sysinfo/board_name | cut -d , -f2)
if [ x${VENDOR} != x"friendlyelec" ]; then
	if [ x${VENDOR} != x"friendlyarm" ]; then
        	logger "only support friendlyelec boards. exiting..."
        	exit 0
	fi
fi

DISABLE_IPV6=0
if [ ${DISABLE_IPV6} -eq 1 ]; then
    # {{ disable ipv6
    uci set 'network.lan.ipv6=off'
    uci set 'network.lan.delegate=0'
    uci set 'network.lan.force_link=0'

    uci set 'network.wan.ipv6=0'
    uci set 'network.wan.delegate=0'
    uci delete 'network.wan6'
    uci commit network

    uci set 'dhcp.lan.dhcpv6=disabled'
    uci set 'dhcp.lan.ra=disabled'
    uci commit dhcp
    # }}
fi

# {{ set ipv6 ip prefix
uci set 'network.globals.ula_prefix=fd00:ab:cd::/48'
uci commit network
# }}

# fix netdata issue
[ -d /usr/share/netdata/web ] && chown -R root:root /usr/share/netdata/web

# Warning:
#     Turning on this option will reduce security
#     To turn it off, set to 0
ENABLE_SIMPLIFIED_SETTINGS=1
if [ ${ENABLE_SIMPLIFIED_SETTINGS} -eq 1 ]; then
    # ttyd: accessible by lan and wan
    [ -f /etc/init.d/ttyd ] && uci delete ttyd.@ttyd[0].interface

    # samba
    if [ -f /etc/samba/smb.conf.template ]; then
        uci set samba.@samba[0].name='FriendlyWrt'
        uci set samba.@samba[0].workgroup='WORKGROUP'
        uci set samba.@samba[0].description='FriendlyWrt'
        uci set samba.@samba[0].homes='1'
        # samba: allow root access
        sed -i -e "/^\s*invalid users\s/s/^/#/" /etc/samba/smb.conf.template
        # samba: accessible by lan and wan
        sed -i -e "/^\s*interfaces\s/s/^/#/" /etc/samba/smb.conf.template
        # samba: set default password to 'password'
        echo "root:0:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:8846F7EAEE8FB117AD06BDD830B7586C:[U          ]:LCT-00000001:" > /etc/samba/smbpasswd
        sed -i '1 i ' /etc/samba/smb.conf.template
        sed -i '1 i #   you can run "smbpasswd -a root" command to change password' /etc/samba/smb.conf.template
        sed -i '1 i #   The default samba credentials: username: root, password: password' /etc/samba/smb.conf.template
        sed -i '1 i # Important note:' /etc/samba/smb.conf.template
    fi

    # remove watchcat setting
    [ -f /etc/init.d/watchcat ] && uci delete system.@watchcat[0]

    uci commit
    [ -f /etc/init.d/watchcat ] && /etc/init.d/watchcat stop
fi

logger "done"
