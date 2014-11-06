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

file { "/etc/exports":
	ensure  => present,
	mode    => 0644,
	content => "
/nfsroot	192.168.10.0/24(rw,no_root_squash,async,insecure,fsid=0,nohide)
/nfsroot/bin	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/etc/alternatives	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/var/lib/apt	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
/nfsroot/var/lib/dpkg	192.168.10.0/24(rw,no_root_squash,async,insecure,nohide)
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

mount { "/nfsroot/etc/alternatives":
	device	=> "/etc/alternatives",
}

mount { "/nfsroot/var/lib/apt":
	device	=> "/var/lib/apt",
}

mount { "/nfsroot/var/lib/dpkg":
	device	=> "/var/lib/dpkg",
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
