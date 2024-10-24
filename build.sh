#!/usr/bin/env bash
# https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso
# iso_download_url="$1"
build_folder="build"
iso_download_path="$1"
read_only_iso_contents_folder="$build_folder/original_mount"
write_custom_iso_contents_folder="$build_folder/custom"
src_folder="src"
iso_output_path="$build_folder/output.iso"
if [ -z "$iso_download_path" ]; then
    echo "Usage: $0 <iso_download_path>"
    exit 1
fi
# check whether xorriso is installed
if ! command -v xorriso >/dev/null 2>&1; then
    echo "xorriso is not installed. Please install it first."
    exit 1
fi
mkdir -p "$read_only_iso_contents_folder" "$write_custom_iso_contents_folder"
hdiutil_attach_output=$(hdiutil attach -nomount "$iso_download_path")
device=$(echo "$hdiutil_attach_output" | head -n1 | grep '/dev/disk' | awk '{print $1}')
mount -t cd9660 "$device" "$read_only_iso_contents_folder"
rsync -av "$read_only_iso_contents_folder/" "$write_custom_iso_contents_folder/"
# Modify the custom folder
rsync -av "$src_folder/" "$write_custom_iso_contents_folder/"
# Build the ISO
captured_args=$(xorriso -indev "$iso_download_path" -report_el_torito as_mkisofs 2>/dev/null | tr '\n' ' ')
cmd="xorriso -as mkisofs -o \"$iso_output_path\" $captured_args \"$write_custom_iso_contents_folder\""
echo "$cmd"
eval "$cmd"
umount "$read_only_iso_contents_folder"
hdiutil detach "$device"
