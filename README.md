# Create cloud-init bootable ISO

## Steps

1. Read this article to roughly understand what we are attempting
    1. https://gist.github.com/AkdM/2cd3766236582ed0263920d42c359e0f
    2. https://askubuntu.com/questions/1390827/how-to-make-ubuntu-autoinstall-iso-with-cloud-init-in-ubuntu-21-10/1391309#1391309
2. (Mac) Install xorriso
    1. https://formulae.brew.sh/formula/xorriso
    2. `curl -L -o "Ubuntu-21.10-live-server-amd64.iso" "~/Downloads/Ubuntu-21.10-live-server-amd64.iso"`
3. (Mac) Install cdrtools (for mkisofs)
    1. https://formulae.brew.sh/formula/cdrtools
4. Download an Ubuntu ISO
5. Build the ISO from your modified files
    1. https://github.com/AndrewJDawes/home-lab-cloud-init/blob/main/bundle.sh
    2. Example: `bash build.sh ~/Downloads/ubuntu-24.04.1-live-server-amd64.iso`
    3. Note that you need the original ISO for reference because xorriso uses that to deduce what build args are required
6. Insert a USB drive to use for booting (will overwrite this)
7. Identify at what device the USB drive is mounted
    1. `diskutil list`
    2. Look for the USB drive, it should be named something like (external, physical)
    3. Note the disk number, e.g. disk4
8. Reformat the USB drive
    1. `diskutil eraseDisk FAT32 ESP /dev/disk4`
    2. https://news.macgasm.net/tips/couldnt-modify-partition-map/
9. **Unmount** the disk (USB drive) (meaning there is no folder mounted on filesystem)
    1. https://www.cybrary.it/blog/macos-terminal-create-bootable-usb-iso-using-dd
    2. `diskutil unmountDisk /dev/disk4`
10. Write the data from the built output ISO to the disk using `dd` to write to the `/dev/rdiskX`
    1. https://www.cybrary.it/blog/macos-terminal-create-bootable-usb-iso-using-dd
    2. https://www.youtube.com/watch?app=desktop&v=B0Et0d-FGR8
    3. Example: `sudo dd if=build/output.iso of=/dev/rdisk4 bs=5m`
    4. Notice how we are writing to the raw disk, not the partition
11. **Eject** the disk (USB drive) (meaning the disk device is no longer available to the system)
    1. `diskutil eject /dev/diskX`
12. Insert the USB drive to the machine you want to boot
13. Start the machine, use the proper F key to enter boot menu
    1. F11 for my machine
14. Select the drive to boot from
    1. Should be named after the maker of your USB drive
    2. Probably prefixed with "UEFI" which stands for Unified Extensible Firmware (used for booting)
        1. https://en.wikipedia.org/wiki/UEFI
15. From this point on, it should start autoinstalling

## Web Server command

`docker run -p 80:80 -v $(pwd)/server:/usr/share/nginx/html nginx`

## Resources

-   Video: https://www.youtube.com/watch?v=DtXZ6BMaKbA&t=70s

## TODO

-   Instead of src/server/meta-data and src/server/user-data, use /etc/cloud/cloud.cfg.d/\*.cfg and specify a NoCloud datasource seedFrom
    -   https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-3-custom-webserver
-   Serve all 4 of these required files from a webserver
    -   https://cloudinit.readthedocs.io/en/latest/reference/datasources/nocloud.html#source-files
    -   You can pass in any secrets
