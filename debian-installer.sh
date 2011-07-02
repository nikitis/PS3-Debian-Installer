#!/bin/bash

### My first attempt at a distribution installer

## Please note that this is a work in progress

## Version 0.89

echo " "
echo "I am in testing phase.  Just so you know.  I may not fully work yet.  Sorry"
echo " "
echo "Currently this script assumes that you have a /dev/ps3dd1 dedicated for swap,"
echo "and /dev/ps3dd2 dedicated for root (/) If this is not the case, please hit"
echo "ctrl-c now to cancel this script as it will not work correctly for the moment."
echo " "
echo "Waiting 15 seconds before continuing. . ."
sleep 15


## Unmounts the partition

echo "Unmounting partition /dev/ps3dd2"
umount /dev/ps3dd2


## Creates the directory to chroot to.

mkdir /mnt/debian


## Choice of type of formatting to be used on ps3dd2
read -p "Which filesystem type do you wish "root" to have?  ext(2/3/4) (s)kip: " A
if [ "$A" = 2 ]; then
        echo "Formatting ext2"
	mkfs.ext2 /dev/ps3dd2
elif [ "$A" = 3 ]; then
        echo "Formatting ext3"
	mkfs.ext3 /dev/ps3dd2
elif [ "$A" = 4 ]; then
        echo "Formatting ext4"
	mkfs.ext4 /dev/ps3dd2
elif [ "$A" = s ]; then
	read -p "Have you already formatted your HDD?  This is different from partitioning. Are you sure you want to skip? (y/n) " B
	if [ "$B" = n ]; then
		read -p "Which filesystem? ext(2/3/4) " A
		if [ "$A" = 2 ]; then
                        echo "Formatting ext2"
			mkfs.ext2 /dev/ps3dd2
		elif [ "$A" = 3 ]; then
                        echo "Formatting ext3"
			mkfs.ext3 /dev/ps3dd2
		elif [ "$A" = 4 ]; then
                        echo "Formatting ext4"
			mkfs.ext4 /dev/ps3dd2
		else
			echo "You failed to hit 2, 3, 4.  You've crashed the script.  Start over."
		fi
	elif [ "$B" = y ]; then
		read -p "Since you have already formatted your parition, what filesytem was used? ext(2/3/4)? " A
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

echo "Copying 2nd half of installer over to post-chrooted environment"
cp ./debian-installer-2.sh /mnt/debian/tmp/debian-installer-2.sh
## Mounting proc as part of chroot.

echo "chrooting. . ."
sleep 1
mount -t proc none /mnt/debian/proc
mount --rbind /dev /mnt/debian/dev
LANG=C chroot /mnt/debian /tmp/debian-installer-2.sh



