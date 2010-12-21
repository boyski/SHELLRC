#!/bin/bash

function whence
{
    unset _flags
    for i in "$@"; do
	case "$i" in
	    -*) _flags=$i; continue ;;
	esac
	_whence=$(type $_flags -p "$i")
	if [[ -n "$_whence" ]]; then
	    echo $_whence
	else
	    type "$i"
	fi
    done
    unset _whence _flags i
}
