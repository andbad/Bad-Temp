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
andbad@hal:~$ cat traffic.sh 
#!/bin/bash
cat <<EOF > /tmp/traffic.tmp
1
EOF

ETHNAME=$@

TRAFFIC=$(ifstat -i $ETHNAME -znq 3 1 | tail -n1)
UP=$(echo $TRAFFIC | awk '/./ && $1 ~ /[0-9]/ {print $2}' | cut -d "." -f1)
DOWN=$(echo $TRAFFIC | awk '/./ && $1 ~ /[0-9]/ {print $1}' | cut -d "." -f1)

cat <<EOF > /tmp/traffic.tmp
0
$UP
$DOWN
EOF
