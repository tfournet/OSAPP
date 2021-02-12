#!/bin/bash

# Stolen from https://gist.github.com/Naoya-Horiguchi/9425402

source /etc/osapp/osapp-vars.conf 

which expect >/dev/null || dnf -y install expect 

usage() {
    echo "Usage: `basename $0` target password logfile <command>"
    exit 0
}

while getopts c: OPT
do
  case $OPT in
    "c" ) export LIBVIRT_DEFAULT_URI=$OPTARG ;;
  esac
done
shift $[OPTIND - 1]

LANG=C
[ $# -lt 3 ] && usage
target=$1
pass=$2
logfile=$3
newpass=$password 
shift 3
cmd="$@"
#echo $cmd
expfile="/tmp/opnsense-expect-script-$$.exp"

echo "Command: $cmd"
echo "Writing to $expfile"

cat <<EOF > $expfile
#!/usr/bin/expect

set timeout 100
set target $target
set pass $pass
set newpass $newpass
log_file -noappend $logfile

spawn virsh console --force $target
expect "Escape character is"
send "\n"
send "\n"
expect "login: " {
    send "root\n"
    expect "Password:"
    send "$pass\n"
} "~]# " {
    send "\n"
}
expect "Enter an option:"
send "8\n"
send "\n"
send "echo start_exec_given_command > /dev/null\n"
send "$cmd\n"
send "exit\n"
expect "Enter an option:"
send "11\n"
expect "Enter an option:"
send "3\n"
expect "y/N]:" 
send "Y\n"
expect "Type a new password:"
send "$newpass\n"
expect "Confirm new password:"
send "$newpass\n"
expect "Enter an option:"
send "6\n"
expect "y/N]:" 
send "Y\n"
expect "login: "
close
EOF

#cat $expfile
echo "Running $expfile"
expect $expfile #> /dev/null
gawk '
    BEGIN { window = 0 }
    /end_exec_given_command/ { window = 0 }
    { if (window == 1) { print } }
    /start_exec_given_command/ { window = 1 }
' $logfile

rm -f $expfile 
