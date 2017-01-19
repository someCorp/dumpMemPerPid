#!/bin/bash
grepBin=/bin/grep
gdbBin=/usr/bin/gdb
sedBin=/bin/sed
mktempBin=/bin/mktemp

if ! [ x`id -u` == "x0" ];then
  echo "dolan plz"
  echo "also ...add glibc-source"
  exit 1
fi

if ! ( [ -x $grepBin ] || [ -x $gdbBin ] || [ -x $sedBin ] );then
 echo "not binaries found, $grepBin or $gdbBin"
 echo "also ...add glibc-source"
 exit 1
fi

if ! [[ $1 =~ ^[[:digit:]]{1,9}$ ]];then
 echo "gaveMe someKind of pid"
 echo "also ...add glibc-source"
 exit 1
fi
tmpDir="$($mktempBin -d)"
cd $tmpDir
$grepBin rw-p /proc/$1/maps | $sedBin -n 's/^\([0-9a-f]*\)-\([0-9a-f]*\) .*$/\1 \2/p' | while read start stop; do $gdbBin --batch --pid $1 -ex "dump memory $1-$start-$stop.dump 0x$start 0x$stop"; done  > /dev/null 2>&1
if [ $PIPESTATUS -eq 0 ];then
  echo "your dumps are in $tmpDir"
else
  echo "something wrong"
fi
cd $OLDPWD
