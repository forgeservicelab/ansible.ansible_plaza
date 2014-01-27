#!/bin/bash

function usage {
  echo "Usage $0 -d <device> -s <headsize>"
}

if test $# -lt 3; then
  usage
fi

while test $# -gt 0; do
  case "$1" in
    -d|--device)
      shift
      if test $# -gt 0; then
        DEVICE=$1
      else
        usage
      fi
      shift
      ;;

    -s|--size)
      shift
      if test $# -gt 0; then
        SIZE=$1
      else
        usage
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

BD=`dd if=$DEVICE bs=1M count=$SIZE | md5sum`
ZD=`dd if=/dev/zero bs=1M count=$SIZE | md5sum`

if [ "$BD" = "$ZD" ]; then
  exit 1 
else
  exit 0
fi
