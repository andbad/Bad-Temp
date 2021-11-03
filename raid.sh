#!/bin/bash
cat <<EOF > /tmp/raid.tmp
1
EOF

IOSTATSDA=$(sudo iostat -mx 1 2 | awk '/sda/ && $1 ~ /[A-z]/')
IOSTATMD2=$(sudo iostat -mx 1 2 | awk '/md2/ && $1 ~ /[A-z]/')

cat <<EOF > /tmp/raid.tmp
0
$IOSTATSDA
$IOSTATMD2
EOF
