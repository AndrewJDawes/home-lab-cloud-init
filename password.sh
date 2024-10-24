#!/usr/bin/env bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <password> <salt>"
    exit 1
fi
# Example: bash password.sh 'test' 'exDY1mhS4KUYCE/2'
# Salt to use: exDY1mhS4KUYCE/2
# Based on example password: "$6$exDY1mhS4KUYCE/2$zmn9ToZwTKLhCw.b4/b.ZRTIZM30JZ4QrOQ2aOXJ8yk96xpcCof0kxKwuX1kqLG/ygbJ1f8wxED22bTL4F46P0"
printf "$1" | openssl passwd -6 -salt "$2" -stdin
