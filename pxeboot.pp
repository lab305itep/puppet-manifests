$packages = [ "dhcp3-server", "tftpd-hpa", "syslinux", "nfs-kernel-server", "initramfs-tools" ]

package { $packages: ensure => "installed" }

service { "isc-dhcp-server":
	ensure  => "running",
	enable  => "true",
	require => Package["dhcp3-server"],
}

file {'dhcpd.conf':
	path    => "/etc/dhcp/dhcpd.conf",
	notify  => Service["isc-dhcp-server"],
	ensure  => present,
	mode    => 0644,
	content => file("/root/dhcpd.conf"),
}

service { "tftpd-hpa":
	ensure  => "running",
	enable  => "true",
	require => Package["tftpd-hpa"],
}

file { "pxelinux.0":
	path    => "/var/lib/tftpboot/pxelinux.0",
	ensure  => present,
	mode    => 0644,
	content => file("/usr/lib/syslinux/pxelinux.0"),
}

file { "menu.c32":
	path    => "/var/lib/tftpboot/menu.c32",
	ensure  => present,
	mode    => 0644,
	content => file("/usr/lib/syslinux/menu.c32"),
}

file { "/var/lib/tftpboot/pxelinux.cfg":
	ensure => "directory",
	mode   => 0644,
}

file { "/var/lib/tftpboot/pxelinux.cfg/default":
	content => "
DEFAULT menu.c32
prompt 0
timeout 1

MENU TITLE PXE Menu

LABEL linux
	MENU DEFAULT
	MENU LABEL Ubuntu, with Linux $kernelrelease
	KERNEL vmlinuz-$kernelrelease
	APPEND boot=nfs root=/dev/nfs initrd=initrd.img-$kernelrelease nfsroot=192.168.10.77:/nfsroot,rw,nolock ip:eth0=dhcp rw
",
}

file { "/nfsroot":
	ensure => "directory",
}

exec { "refresh_exports":
	command => "exportfs -rv",
	path    => "/usr/sbin/"
}

# SYMLINKS

file { "/etc/mtab":
	require => File["/var/etc/mtab"],
	ensure	=> "link",
	target	=> "../var/etc/mtab",
}

file { "/etc/fstab":
	require => File["/var/etc/fstab"],
	ensure  => "link",
	target  => "../var/etc/fstab",
}

file{ "/etc/hostname":
	require	=> File["/var/etc/hostname"],
	ensure	=> "link",
	target	=> "../var/etc/hostname",
}

file{ "/etc/network/interfaces":
	require	=> File["/var/etc/network/interfaces"],
	ensure	=> "link",
	target	=> "../../../var/etc/network/interfaces",
}

file{ "/etc/rc0.d":
	require	=> File["/var/etc/rc0.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc0.d",
}

file{ "/etc/rc1.d":
	require	=> File["/var/etc/rc1.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc1.d",
}

file{ "/etc/rc2.d":
	require	=> File["/var/etc/rc2.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc2.d",
}

file{ "/etc/rc3.d":
	require	=> File["/var/etc/rc3.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc3.d",
}

file{ "/etc/rc4.d":
	require	=> File["/var/etc/rc4.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc4.d",
}

file{ "/etc/rc5.d":
	require	=> File["/var/etc/rc5.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc5.d",
}

file{ "/etc/rc6.d":
	require	=> File["/var/etc/rc6.d"],
	ensure	=> "link",
	target	=> "../var/etc/rc6.d",
}

# SERVER'S /var/etc/

file { "/var/etc/mtab":
	ensure	=> "present",
}

file { "/var/etc/fstab":
	content	=> file("/etc/fstab"),
}

file { "/var/etc/hostname":
	content	=> "kserver",
}

file { "/var/etc/network/interfaces":
	ensure	=> "exists",
#	content	=> file("/etc/network/interfaces"),
}

file { "/var/etc/network":
	ensure	=> "directory",
}

file { "/var/etc":
	ensure	=> "directory",
}

file { "/var/etc/rc0.d":
	ensure	=> "directory",
}

file { "/var/etc/rc1.d":
	ensure	=> "directory",
}

file { "/var/etc/rc2.d":
	ensure	=> "directory",
}

file { "/var/etc/rc3.d":
	ensure	=> "directory",
}

file { "/var/etc/rc4.d":
	ensure	=> "directory",
}

file { "/var/etc/rc5.d":
	ensure	=> "directory",
}

file { "/var/etc/rc6.d":
	ensure	=> "directory",
}

# make sure that symlinks in /etc/rcN.d are working
file { "/var/etc/init.d":
	ensure	=> "link",
	target	=> "../../etc/init.d",
}

# CLIENT'S /nfsroot/var/etc/

file { "/nfsroot/var/etc/hostname":
	content	=> "",
}

file { "/nfsroot/var/etc/network/interfaces":
	content	=> "
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
",
}

file { "/nfsroot/var/etc/network":
	ensure	=> "directory"
}

file { "/nfsroot/var/etc":
	ensure	=> "directory"
}

# make sure that symlinks in /etc/rcN.d are working
file { "/nfsroot/var/etc/init.d":
	ensure	=> "link",
	target	=> "../../etc/init.d",
}

file { "/etc/exports":
	ensure  => present,
	mode    => 0644,
	content => "
/nfsroot	192.168.10.0/24(rw,no_root_squash,async,insecure,fsid=0,nohide)
/nfsroot/bin	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/etc	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/var/lib/apt	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/var/lib/dpkg	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/var/lib/update-notifier	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/home	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/lib	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/root	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/sbin	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/usr	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
",
	notify  => Exec["refresh_exports"],
}

Mount {
	ensure	=> 'mounted',
	atboot	=> yes,
	fstype	=> "none",
	options	=> "bind",
}

mount { "/nfsroot/bin":
	device	=> "/bin",
}

mount { "/nfsroot/etc":
	device	=> "/etc",
}

mount { "/nfsroot/var/lib/apt":
	device	=> "/var/lib/apt",
}

mount { "/nfsroot/var/lib/dpkg":
	device	=> "/var/lib/dpkg",
}

mount { "/nfsroot/var/lib/update-notifier":
	device	=> "/var/lib/update-notifier",
}

file { "/nfsroot/var/lib/update-notifier":
	ensure	=> "directory",
}

mount { "/nfsroot/home":
	device	=> "/home",
}

mount { "/nfsroot/lib":
	device	=> "/lib",
}

mount { "/nfsroot/root":
	device	=> "/root",
}

mount { "/nfsroot/sbin":
	device	=> "/sbin",
}

mount { "/nfsroot/usr":
	device	=> "/usr",
}

file { "/var/lib/tftpboot/initrd.img-$kernelrelease":
	ensure  => present,
	mode    => 0644,
	content => file("/boot/initrd.img-$kernelrelease"),
}

file { "/var/lib/tftpboot/vmlinuz-$kernelrelease":
	ensure  => present,
	mode    => 0644,
	content => file("/boot/vmlinuz-$kernelrelease"),
}
