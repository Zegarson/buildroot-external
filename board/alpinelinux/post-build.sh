set -e

config_isset() {
	grep -Eq "^$1=" "$BR2_CONFIG"
}

config_string() {
	sed -n "/^$1/s,.*=\"\(.*\)\",\1,p" "$BR2_CONFIG"
}

# FSTAB
if config_isset "BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW"
then
    # Comment /dev/root entry in fstab. When openrc does not find fstab entry for
    # "/", it will try to remount "/" as "rw".
    sed -e '\:^/dev/root[[:blank:]]:s/^/# /' -i "$TARGET_DIR/etc/fstab"
else
    # Uncomment /dev/root entry in fstab which has "ro" option so openrc notices
    # it and doesn't remount root to rw.
    sed -e '\:^#[[:blank:]]*/dev/root[[:blank:]]:s/^# //' -i "$TARGET_DIR/etc/fstab"
fi

# GETTY
if config_isset "BR2_TARGET_GENERIC_GETTY"
then
	port="$(config_string "BR2_TARGET_GENERIC_GETTY_PORT")"
	rate="$(config_string "BR2_TARGET_GENERIC_GETTY_BAUDRATE")"
	term="$(config_string "BR2_TARGET_GENERIC_GETTY_TERM")"
	opts="$(config_string "BR2_TARGET_GENERIC_GETTY_OPTIONS")"

	line="$port::respawn:/sbin/getty -L${opts:+$opts} $port $rate $term"
	if ! grep -q "^$line\$" "$TARGET_DIR/etc/inittab"
	then
		cat <<EOF >>"$TARGET_DIR/etc/inittab"
# Put a getty on the serial port
$line
EOF
	fi

	if ! grep -q "^$port\$" "$TARGET_DIR/etc/securetty"
	then
		cat <<EOF >>"$TARGET_DIR/etc/securetty"
$port
EOF
	fi
fi

# DHCP
if config_isset "BR2_SYSTEM_DHCP"
then
	iface="$(config_string "BR2_SYSTEM_DHCP")"
	line="iface $iface inet dhcp"
	if ! grep -q "^$line\$" "$TARGET_DIR/etc/network/interfaces"
	then
		cat <<EOF >"$TARGET_DIR/etc/network/interfaces"
auto $iface
iface $iface inet dhcp
EOF
	fi
fi

# INIT SERVICES
ln -sf /etc/init.d/{modules,sysctl,hostname,bootmisc,syslog,devfs,procfs,sysfs} "$TARGET_DIR/etc/runlevels/boot/"
ln -sf /etc/init.d/{dmesg,hwdrivers} "$TARGET_DIR/etc/runlevels/sysinit/"
ln -sf /etc/init.d/{local,networking,wpa_cli,ntpd,sshd} "$TARGET_DIR/etc/runlevels/default/"
ln -sf /etc/init.d/{mount-ro,killprocs,savecache} "$TARGET_DIR/etc/runlevels/shutdown/"

# ADD INIT.D SERVICES
if grep -q "^f:" "$TARGET_DIR/lib/apk/db/installed"
then
	ln -sf /etc/init.d/apk-fix "$TARGET_DIR/etc/runlevels/default/"
fi