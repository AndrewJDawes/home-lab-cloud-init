#!/bin/bash
original_iso="$1"    # /path/to/ubuntu-24.04.1-live-server-amd64.iso
modified_folder="$2" # /new
output_iso="$3"      # output.iso
if [ -z "$original_iso" ] || [ -z "$modified_folder" ] || [ -z "$output_iso" ]; then
    echo "Usage: $0 <original_iso> <modified_folder> <output_iso>"
    exit 1
fi
captured_args=$(xorriso -indev "$original_iso" -report_el_torito as_mkisofs 2>/dev/null | tr '\n' ' ')
xorisso_binary=$(which xorriso)
cmd="$xorisso_binary -as mkisofs -o \"$output_iso\" $captured_args \"$modified_folder\""
echo "$cmd"
eval "$cmd"
