#!/bin/bash

############# Section 2 of Debian Installer ###########
## Had to add this section due to chrooting process. ##
#######################################################


## Adding color to terminal

export TERM=xterm-color

###################### End of Chrooting Process ######################



## Setting up fstab

echo " "
echo "Setting up fstab entries. . ."
echo " "
sleep 3
echo -e "/dev/ps3dd2	/		ext$A	defaults		0 1\n/dev/ps3vram	none		swap	sw			0 0\n/dev/ps3dd1	none		swap	sw			0 0\n/dev/sr0	/mnt/cdrom	auto	noauto,ro		0 0\nproc		/proc		proc	defaults		0 0\nshm		/dev/shm	tmpfs	nodev,nosuid,noexec	0 0\n" > /etc/fstab


## Setting up timezone

echo " "
echo "Setting up timezone data"
echo " "
sleep 3
touch /etc/default/rcS

dpkg-reconfigure tzdata


## Configuring Network Data

read -p "Please enter the name of your Playstation 3 (No spaces or odd characters): " D
echo " "
echo "Saving $D into /etc/hostname"
echo $D > /etc/hostname


## Setting up /etc/network/interfaces

echo " "
echo "Setting up network interfaces"
echo " "
echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces


## Setting up /etc/resolv.conf

echo " "
read -p "If you have a different gateway other than 192.168.1.1, please enter it in. Otherwise press n: " E
if [ "$E" = n ]; then
	echo "nameserver 192.168.1.1" > /etc/resolv.conf
else
	echo -e "nameserver $E" > /etc/resolv.conf
fi
echo " "

## Configuring aptitude sources in /etc/apt/sources.list

echo " "
echo "Creating entries for aptitude."
echo " "
sleep 3
echo -e "deb http://ftp.us.debian.org/debian squeeze main\ndeb-src http://ftp.us.debian.org/debian squeeze main\n\ndeb http://security.debian.org/ squeeze/updates main\ndeb-src http://security.debian.org/ squeeze/updates main\n" > /etc/apt/sources.list


## Updating packages for Debian install

echo " "
echo "Updating base install package index."
echo " "
aptitude update
echo " "
echo "Setting up locales and console-data.  For english set en-us."
echo " "
sleep 5

aptitude install locales
dpkg-reconfigure locales
aptitude install console-data
dpkg-reconfigure console-data


## Finishing touches

echo " "
echo "Installing other packages that are needed."
echo " "
sleep 5

echo " "
echo "Starting tasksel. . ."
sleep 3

tasksel install standard
echo "Cleaning up install packages to save space on HDD. . ."
aptitude clean
echo "Please set a new root password."
passwd

echo " "
echo "Installing development packages for kernel build"
echo " "
aptitude install git build-essential ncurses-dev


## Creating Swap Parition and Enabling

echo " "
echo "Setting Swap Parition and Enabling."
echo " "
mkswap /dev/ps3dd1
swapon /dev/ps3dd1

## Kernal compiling (Still very beta)

git clone git://git.gitbrew.org/ps3/ps3linux/linux-2.6.git /usr/src/
ln -sf linux-2.6 linux
cd linux
cp ps3_linux_config .config
make menuconfig
make
make install
make modules_install


## Creating kboot.conf entry

echo " "
echo "Creating kboot.conf entries. . ."
echo " "
echo -e "debian=/boot/vmlinux-2.6.* root=/dev/ps3dd2\ndebian_Hugepages=/boot/vmlinux-2.6.* root=/dev/ps3dd2 hugepages=1" > /etc/kboot.conf


## Creating /dev/ps3flash device for ps3-utils

echo " "
echo -e "Creating udev device \"ps3vflash\" for ps3-utils"
echo " "
echo -e "KERNEL==\"ps3vflash\", SYMLINK+=\"ps3flash\"" > /etc/udev/rules.d/70-persistent-ps3flash.rules


## Finished

echo " "
echo "Installation is complete."
echo " "
echo "Type Reboot.  Next time you are in petitboot, select your new entry to boot debian."
echo " " 
echo "Enjoy!  This installer was written by nikitis from Gitbrew."

