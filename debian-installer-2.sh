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
echo -e "/dev/ps3dd2	/		extextvar	defaults		0 1\n/dev/ps3vram	none		swap	sw			0 0\n/dev/ps3dd1	none		swap	sw			0 0\n/dev/sr0	/mnt/cdrom	auto	noauto,ro		0 0\nproc		/proc		proc	defaults		0 0\nshm		/dev/shm	tmpfs	nodev,nosuid,noexec	0 0\n" > /etc/fstab


## Setting up timezone

echo "Setting up timezone data"
echo " "
touch /etc/default/rcS
dpkg-reconfigure tzdata


## Configuring Network Data

read -p "Please enter the name of your Playstation 3 (No spaces or odd characters): " D
echo " "
echo "Saving $D into /etc/hostname"
echo $D > /etc/hostname
touch /etc/hosts
echo "127.0.0.1		localhost" > /etc/hosts

## Setting up /etc/network/interfaces

echo " "
echo "Setting up network interfaces"
echo " "
echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces


## Configuring aptitude sources in /etc/apt/sources.list

echo " "
echo "Creating entries for sources.list"
echo " "
echo -e "deb http://ftp.us.debian.org/debian squeeze main\ndeb-src http://ftp.us.debian.org/debian squeeze main\n\ndeb http://security.debian.org/ squeeze/updates main\ndeb-src http://security.debian.org/ squeeze/updates main\n" > /etc/apt/sources.list


## Updating packages for Debian install

echo " "
echo "Updating base install package index."
echo " "
aptitude update
echo " "
echo "Setting up locales and console-data.  For english set en-us-UTF8."
echo " "

aptitude -y install locales
dpkg-reconfigure locales
aptitude -y install console-data
dpkg-reconfigure console-data
echo "LC_ALL=\"en_US.UTF-8\"" >> /etc/default/locale

## Finishing touches

echo " "
echo "Installing other packages that are needed."
echo " "
sleep 2

echo " "
echo "Starting tasksel. . ."
sleep 3

tasksel install standard
echo "Cleaning up install packages to save space on HDD. . ."
aptitude clean


## User creation and password setting
echo "Starting user creation and password entries..."

echo "Please set a new root password."
passwd
echo " "

read -p "Please enter in a username you would like to use: " F
if [ "$F" = "" ]; then
	echo "That username was not valid"
else
	echo "Creating user $F"
	adduser $F
fi 

## Adding user to sudoers file
echo "Adding user to sudoers file"
usermod -aG sudo $F

echo " "
echo "Installing development packages for kernel build"
echo " "
aptitude -y install git build-essential ncurses-dev


## Creating Swap Parition and Enabling

echo " "
echo "Setting Swap Parition and Enabling."
echo " "
mkswap /dev/ps3dd1
swapon /dev/ps3dd1


## Git cloning of Kernal)
echo "Downloading kernel source from git and creating symlink"
cd /usr/src
wget http://gotbrew.org/git/linux-2.6.tar.gz
tar -xvf linux-2.6.tar.gz
ln -sf /usr/src/linux-2.6 /usr/src/linux
cp /usr/src/linux/ps3_linux_config /usr/src/linux/.config


## Kernel compilation

echo " "
echo "Starting compilation of kernel. (Takes around 1 hour or less.)"
cd /usr/src/linux
make menuconfig
make
make install
make modules_install
cd /
rm linux-2.6.tgz
echo " "
echo "Kernel compiling is done if no errors occured."
echo " "


## Creating kboot.conf entry

echo " "
echo "Creating kboot.conf entries. . ."
echo " "

E=`ls /boot | grep vmlinux`

echo -e "debian=/boot/$E root=/dev/ps3dd2\ndebian_Hugepages=/boot/$E root=/dev/ps3dd2 hugepages=1" > /etc/kboot.conf


## Creating /dev/ps3flash device for ps3-utils

echo " "
echo -e "Creating udev device \"ps3vflash\" for ps3-utils"
echo " "
echo -e "KERNEL==\"ps3vflash\", SYMLINK+=\"ps3flash\"" > /etc/udev/rules.d/70-persistent-ps3flash.rules


## Finished

echo " "
echo "Installation is complete. Upon reboot, select your new kboot entry to boot Debian."
echo " "
read -p "Press any key to reboot.  (If system hangs, hold power button for 8 seconds.)"

echo " " 
echo "Enjoy!"

reboot

