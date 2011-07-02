#!/bin/bash

############# Section 2 of Debian Installer ###########
## Had to add this section due to chrooting process. ##
#######################################################


## Adding color to terminal

export TERM=xterm-color

###################### End of Chrooting Process ######################



## Setting up fstab

echo "Setting up fstab entries. . ."
sleep 2
echo -e "/dev/ps3dd2	/		ext$A	defaults		0 1\n/dev/ps3vram	none		swap	sw			0 0\n/dev/ps3dd1	none		swap	sw			0 0\n/dev/sr0	/mnt/cdrom	auto	noauto,ro		0 0\nproc		/proc		proc	defaults		0 0\nshm		/dev/shm	tmpfs	nodev,nosuid,noexec	0 0\n" > /etc/fstab


## Setting up timezone

echo "Setting up timezone data"

touch /etc/default/rcS

dpkg-reconfigure tzdata


## Configuring Network Data

read -p "Please enter the name of your Playstation 3 (No spaces or odd characters): " D
echo "Saving $D into /etc/hostname"
echo $D > /etc/hostname


## Setting up /etc/network/interfaces

echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces


## Setting up /etc/resolv.conf

read -p "If you have a different gateway other than 192.168.1.1, please enter it in. Otherwise press n: " E
if [ "$E" = n ]; then
	echo "nameserver 192.168.1.1" > /etc/resolv.conf
else
	echo -e "nameserver $E" > /etc/resolv.conf
fi


## Configuring aptitude sources in /etc/apt/sources.list

echo -e "deb http://ftp.us.debian.org/debian squeeze main\ndeb-src http://ftp.us.debian.org/debian squeeze main\n\ndeb http://security.debian.org/ squeeze/updates main\ndeb-src http://security.debian.org/ squeeze/updates main\n" > /etc/apt/sources.list


## Updating packages for Debian install

echo "Installing and setting up locales.  For english set en-us."
sleep 5
aptitude install locales
dpkg-reconfigure locales
aptitude install console-data
dpkg-reconfigure console-data


## Finishing touches

echo "Installing other packages that are needed"
tasksel install standard
echo "Cleaning up install packages to save space on HDD. . ."
aptitude clean
echo "Please set a root password."
passwd


## Kernal compiling (Still very beta)

cd /usr/src
git clone git://git.gitbrew.org/ps3/ps3linux/linux-2.6.git
ln -sf linux-2.6 linux
cd linux
cp ps3_linux_config .config
make menuconfig
make
make install
make modules_install


## Creating kboot.conf entry

echo "Creating kboot.conf entries. . ."
echo -e "debian=/boot/vmlinux-2.6.* root=/dev/ps3dd2\ndebian_Hugepages=/boot/vmlinux-2.6.* root=/dev/ps3dd2 hugepages=1" > /etc/kboot.conf


## Creating /dev/ps3flash device for ps3-utils

echo -e "Creating udev device \"ps3vflash\" for ps3-utils"
echo -e "KERNEL==\"ps3vflash\", SYMLINK+=\"ps3flash\"" > /etc/udev/rules.d/70-persistent-ps3flash.rules


## Finished

echo -e "Installation is complete.  Hit enter on your keyboard and immediately unplug the usb keyboard.  If it did not boot and you see \"System is going down for reboot\" message and did not boot the new kernel, then you probably weren't fast enough but try again."
