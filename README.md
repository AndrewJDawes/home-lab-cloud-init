# Create cloud-init bootable ISO

## Steps

1. Download an Ubuntu ISO
1. (Mac) Install cdrtools (for mkisofs)
    1. https://formulae.brew.sh/formula/cdrtools
1. (Mac) Install xorisso
    1. https://formulae.brew.sh/formula/xorriso
1. Insert a USB drive to use for booting (will overwrite this)
1. Reformat the USB drive
    1. diskutil eraseDisk FAT32 ESP /dev/disk4
    1. https://news.macgasm.net/tips/couldnt-modify-partition-map/
1. Read this article to roughly understand what we are attempting
    1. https://gist.github.com/AkdM/2cd3766236582ed0263920d42c359e0f
    1. https://askubuntu.com/questions/1390827/how-to-make-ubuntu-autoinstall-iso-with-cloud-init-in-ubuntu-21-10/1391309#1391309
1. Create a read-only and a write folder
    1. `mkdir ro_iso && mkdir new`
1. Use hdiutil to attach the downloaded Ubuntu ISO **without** mounting it
    1. `hdiutil attach -nomount <UBUNTU.ISO>`
1. Identify where the disk device is at (what number)
    1. `diskutil list`
    1. Look for the entry that says `(disk image)`
1. Mount the disk into the read-only folder
    1. `mount -t cd9660 /dev/disk2 ro_iso`
1. Copy all the files from the read-only folder to the write folder
    1. `rsync -av ro_iso/ new/`
1. Start making your edits in the write folder - see below.
1. Patch new/boot/grub/grub.cfg as follows:

    1. Modify `set timeout=30` to `set timeout=1`
    1. Edit the top `menuentry` as follows:

    ```
    menuentry "autoinstall" {
        set gfxpayload=keep
        linux  /casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/server/ ---
        initrd /casper/initrd
    }
    ```

1. Add the cloud-init files as follows (the encrypted password is "ubuntu"):

```
mkdir new/server
touch new/server/meta-data
cat << _EOF_ > new/server/user-data
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-server
    password: "$6$exDY1mhS4KUYCE/2$zmn9ToZwTKLhCw.b4/b.ZRTIZM30JZ4QrOQ2aOXJ8yk96xpcCof0kxKwuX1kqLG/ygbJ1f8wxED22bTL4F46P0"
    username: ubuntu
```

1. Build the ISO from your modified files
    1. https://github.com/AndrewJDawes/home-lab-cloud-init/blob/main/bundle.sh
    2. Example: `bash bundle.sh Ubuntu-21.10-live-server-amd64.iso new/ ubuntu-autoinstall.iso`
    3. Note that you need the original ISO for reference because xorisso uses that to deduce what build args are required
2. Unmount the disk (USB drive)
    1. https://www.cybrary.it/blog/macos-terminal-create-bootable-usb-iso-using-dd
3. Write the data from the folder to the disk using `dd` to write to the `/dev/rdiskX`
    1. https://www.cybrary.it/blog/macos-terminal-create-bootable-usb-iso-using-dd
    2. https://www.youtube.com/watch?app=desktop&v=B0Et0d-FGR8
4. Eject the disk (USB drive)
    1. `diskutil eject diskX`
5. Insert the USB drive to the machine you want to boot
6. Start the machine, use F key to enter boot menu
    1. F11 for my machine
7. Select the drive to boot from
    1. Should be named after the maker of your USB drive
    2. Probably prefixed with "UEFI" which stands for Unified Extensible Firmware (used for booting)
        1. https://en.wikipedia.org/wiki/UEFI
8. From this point on, it should start autoinstalling

## Resources

-   Video: https://www.youtube.com/watch?v=DtXZ6BMaKbA&t=70s
