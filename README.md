# Create cloud-init bootable ISO

## Steps

1. Download an Ubuntu ISO
1. (Mac) Install cdrtools (for mkisofs)
    1. https://formulae.brew.sh/formula/cdrtools
1. (Mac) Install xorisso
    1. https://formulae.brew.sh/formula/xorriso
1. Read this article to roughly understand what we are attempting
    1. https://gist.github.com/AkdM/2cd3766236582ed0263920d42c359e0f
    2. https://askubuntu.com/questions/1390827/how-to-make-ubuntu-autoinstall-iso-with-cloud-init-in-ubuntu-21-10/1391309#1391309
1. Build the ISO from your modified files
    1. https://github.com/AndrewJDawes/home-lab-cloud-init/blob/main/bundle.sh
    2. Example: `bash bundle.sh Ubuntu-21.10-live-server-amd64.iso new/ ubuntu-autoinstall.iso`
    3. Note that you need the original ISO for reference because xorisso uses that to deduce what build args are required
1. Insert a USB drive to use for booting (will overwrite this)
1. Identify at what device the USB drive is mounted
    1. diskutil list
    2. Look for the USB drive, it should be named something like (external, physical)
    3. Note the disk number, e.g. disk4
1. Reformat the USB drive
    1. diskutil eraseDisk FAT32 ESP /dev/disk4
    2. https://news.macgasm.net/tips/couldnt-modify-partition-map/
1. **Unmount** the disk (USB drive) (meaning there is no folder mounted on filesystem)
    1. https://www.cybrary.it/blog/macos-terminal-create-bootable-usb-iso-using-dd
    2. `diskutil unmountDisk /dev/disk4`
1. Write the data from the folder to the disk using `dd` to write to the `/dev/rdiskX`
    1. https://www.cybrary.it/blog/macos-terminal-create-bootable-usb-iso-using-dd
    2. https://www.youtube.com/watch?app=desktop&v=B0Et0d-FGR8
    3. Example: `sudo dd if=build/output.iso of=/dev/rdisk4 bs=5m`
    4. Notice how we are writing to the raw disk, not the partition
1. **Eject** the disk (USB drive) (meaning the disk device is no longer available to the system)
    1. `diskutil eject /dev/diskX`
1. Insert the USB drive to the machine you want to boot
1. Start the machine, use the proper F key to enter boot menu
    1. F11 for my machine
1. Select the drive to boot from
    1. Should be named after the maker of your USB drive
    2. Probably prefixed with "UEFI" which stands for Unified Extensible Firmware (used for booting)
        1. https://en.wikipedia.org/wiki/UEFI
1. From this point on, it should start autoinstalling

## Resources

-   Video: https://www.youtube.com/watch?v=DtXZ6BMaKbA&t=70s

## TODO

-   Instead of src/server/meta-data and src/server/user-data, use /etc/cloud/cloud.cfg.d/\*.cfg and specify a NoCloud datasource seedFrom
    -   https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-3-custom-webserver
-   Serve all 4 of these required files from a webserver
    -   https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-files
    -   You can pass in any secrets
