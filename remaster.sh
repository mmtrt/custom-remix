#!/bin/bash

sudo apt-get update && sudo apt-get -y install isolinux genisoimage squashfs-tools xorriso zsync

echo "Download the ISO to be customized..."
URL=https://github.com/mmtrt/unity-remix/releases/download/continuous/unity-remix-20.04-desktop-amd64.iso
wget "$URL" --progress=dot -e dotbytes=100M

mv *.iso original.iso

echo "Mount the ISO..."

mkdir mnt
sudo mount -o loop,ro original.iso mnt/

echo "Extract .iso contents into dir 'extract-cd'..."

mkdir extract-cd
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

echo "Extract the SquashFS filesystem..."

sudo unsquashfs -n mnt/casper/filesystem.squashfs
sudo mv squashfs-root edit

echo "Prepare chroot..."

# Mount needed pseudo-filesystems for the chroot
sudo mount --rbind /sys edit/sys
sudo mount --rbind /dev edit/dev
sudo mount -t proc none edit/proc
sudo mount -o bind /run/ edit/run
sudo cp /etc/hosts edit/etc/
sudo rm -rf edit/etc/resolv.conf || true
sudo cp /etc/resolv.conf edit/etc/

echo "Moving customization script to chroot..."
sudo cp customize.sh edit/customize.sh

echo "Entering chroot..."

sudo chroot edit <<EOF

echo "In chroot: adding i386 support..."
sudo dpkg --add-architecture i386

echo "In chroot: apt commands..."
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get autoclean

echo "In chroot: Run customization script..."
chmod +x customize.sh && ./customize.sh && rm ./customize.sh

echo "In chroot: remove old kernel remains..."
sudo apt-get purge -y linux-headers-$(ls edit/lib/modules | head -1 | sed 's|-g.*||') linux-*-headers-$(ls edit/lib/modules | head -1 | sed 's|-g.*||') linux-headers-$(ls edit/lib/modules | head -1) linux-image-$(ls edit/lib/modules | head -1) linux-modules-$(ls edit/lib/modules | head -1) linux-modules-extra-$(ls edit/lib/modules | head -1) linux-generic linux-headers-generic linux-image-generic

echo "In chroot: Delete temporary files..."
( cd /etc ; sudo rm resolv.conf ; sudo ln -s ../run/systemd/resolve/stub-resolv.conf resolv.conf )

echo "In chroot: Clearing cache files..."
rm -rf /tmp/*
sudo rm /etc/apt/sources.list.save
sudo rm -rf /var/cache/apparmor/*
sudo rm /var/cache/app-info/cache/en_US.cache
sudo rm /var/cache/debconf/{config.dat-old,templates.dat-old}
sudo rm /var/cache/apt/*.bin
sudo rm /var/cache/apt/archives/*.deb
sudo rm /var/lib/dpkg/status-old
sudo rm /etc/hosts && sudo touch /etc/hosts
exit
EOF

echo "Exiting chroot..."

# Unmount pseudo-filesystems for the chroot
sudo umount -lfr edit/proc
sudo umount -lfr edit/sys
sudo umount -lfr edit/dev
sudo umount -lfr edit/run

ls edit/lib/modules
ls edit/boot

echo "Copying initramfs to casper..."
sudo rm extract-cd/casper/{initrd,vmlinuz}
sudo cp edit/boot/initrd.img-*xanmod* extract-cd/casper/initrd
sudo cp edit/boot/vmlinuz-*xanmod* extract-cd/casper/vmlinuz
sudo rm edit/boot/{initrd.img-*,vmlinuz-*}

echo "Repacking..."

sudo chmod +w extract-cd/casper/filesystem.manifest

sudo su <<HERE
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest <<EOF
exit
EOF
HERE

sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -noappend
echo ">>> Recomputing MD5 sums"

sudo su <<HERE
( cd extract-cd/ && find . -type f -not -name md5sum.txt -not -path '*/isolinux/*' -print0 | xargs -0 -- md5sum > md5sum.txt )
exit
HERE

cd extract-cd 	
sudo xorriso -as mkisofs \
	-V "Unity Remix 20.04 LTS amd64" \
	-J -joliet-long \
	-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
	-c isolinux/boot.cat \
	-b isolinux/isolinux.bin \
	-no-emul-boot \
	-boot-load-size 4 \
	-boot-info-table \
	-eltorito-alt-boot \
	-e boot/grub/efi.img \
	-no-emul-boot \
	-isohybrid-gpt-basdat \
	-o ../unity-remix-20.04-desktop-amd64.iso \
       "../extract-cd"
sudo chown -R $USER ../*iso

cd ..

rm original.iso

# Write update information for use by AppImageUpdate; https://github.com/AppImage/AppImageSpec/blob/master/draft.md#update-information
echo "gh-releases-zsync|mmtrt|custom-remix|latest|unity-*amd64.iso.zsync" | dd of="unity-remix-20.04-desktop-amd64.iso" bs=1 seek=33651 count=512 conv=notrunc

# Write zsync file
zsyncmake *.iso

ls -lh *.iso
