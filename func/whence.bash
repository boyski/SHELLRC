#!/bin/bash

function whence
{
    for i in "$@"; do
	_whence=$(type -p "$i")
	if [[ -n "$_whence" ]]; then
	    echo $_whence
	else
	    type "$i"
	fi
    done
    unset _whence i
}
