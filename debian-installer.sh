#!/bin/bash

## My first attempt at a distribution installer

## Please note that this is a work in progress

## Version 0.71

echo "I am in testing phase.  Just so you know.  I may not fully work yet.  Sorry"
echo "Currently this script assumes that you have a /dev/ps3dd1 dedicated for swap, and /dev/ps3dd2 dedicated for root (/) If this is not the case, please it ctrl-c now to cancel this script as it will not work correctly for the moment.  Waiting 5 seconds before continuing"
sleep 5

## Unmounts the partition
echo "Unmounting partition /dev/ps3dd2
umount /dev/ps3dd2

## Creates the directory to chroot to.
mkdir /mnt/debian

## Choice of type of formatting to be used on ps3dd2
read -p "Which filesystem type do you wish \"/\" to have?  ext(2/3/4) (s)kip" A
if [ "$A" = 2 ]; then
	mkfs.ext2 /dev/ps3dd2
elif [ "$A" = 3 ]; then
	mkfs.ext3 /dev/ps3dd2
elif [ "$A" = 4 ]; then
	mkfs.ext4 /dev/ps3dd2
elif [ "$A" = s ]; then 
	read -p "Have you already formatted your HDD?  This is different from partitioning. Are you sure you want to skip? (y/n)" B
	if [ "$B" = n ]; then
		read -p "Which filesystem? ext(2/3/4)" C
		if [ "$C" = 2 ]; then
			mkfs.ext2 /dev/ps3dd2
		elif [ "$C" = 3 ]; then
			mkfs.ext3 /dev/ps3dd2
		elif [ "$C" = 4 ]; then
			mkfs.ext4 /dev/ps3dd2
		else
			echo "You failed to hit 2, 3, 4.  You've crashed the script.  Start over."
		fi
	elif [ "$B" = y ]; then 
		read -p "Since you have already formatted your parition, what filesytem was used? ext(2/3/4)? A
			echo "Skipping formatting process."
	else 
		echo "You did not hit y or n.  You have crashed the script."
	fi
else
	echo "You failed to select 2, 3, 4, or s.  You probably shouldn't be installing linux on your PS3"
fi


## Mounts / to /mnt/debian/
mount /dev/ps3dd2 /mnt/debian

## This step is used for when the script is re-run 
echo "Cleaning formatted drive. . ."
rm -rf /mnt/debian*

## Debootstrap
echo "Debootstrapping. . ."
debootstrap --arch powerpc squeeze /mnt/debian http://ftp.us.debian.org/debian

## Mounting proc as part of chroot.
echo "chrooting. . ."
sleep 1
mount -t proc none /mnt/debian/proc
mount --rbind /dev /mnt/debian/dev
LANG=C chroot /mnt/debian /bin/bash

## Adding color to terminal
export TERM=xterm-color

###################### End of Chrooting Process ######################

## Setting up fstab
echo "Setting up fstab entries. . ."
sleep 2
echo -e "/dev/ps3dd2	/		ext$A	defaults		0 1\n/dev/ps3vram	none		swap	sw			0 0\n/dev/ps3dd1	none		swap	sw			0 0\n/dev/sr0	/mnt/cdrom	auto	noauto,ro		0 0\nproc		/proc		proc	defaults		0 0\nshm		/dev/shm	tmpfs	nodev,nosuid,,noexec	0 0\n" > /etc/fstab

## Setting up timezone
echo "Setting up timezone data"

touch /etc/default/rcS

dpkg-reconfigure tzdata

## Configuring Network Data
read -p "Please enter the name of your Playstation 3 (No spaces or odd characters)>" D
echo "Saving $D into /etc/hostname"
echo $D > /etc/hostname

## Setting up /etc/network/interfaces
echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet dhcp\n"

## Setting up /etc/resolv.conf
read -p "If you have a different gateway other than 192.168.1.1, please enter it in. Otherwise press n:" E
if [ "$E" = n ]; then
	echo "nameserver 192.168.1.1" > /etc/resolv.conf
else
	echo -e "nameserver $E" > /etc/resolv.conf
fi

## Configuring aptitude sources in /etc/apt/sources.list
echo -e "deb http://ftp.us.debian.org/debian/squeeze main\ndeb-src http://ftp.us.debian.org/debian squeeze main\n\ndeb http://security.debian.org/ squeeze/updates main\ndeb-src http://security.debian.org/ squeeze/updates main\n"

## Updating packages for Debian install
echo "Installing and setting up locales.  For english set en-us.
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

