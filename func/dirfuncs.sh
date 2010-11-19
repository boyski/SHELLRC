#!shell (just so 'file' says the right thing)

# Written by David Boyce 1995.

###########################################################################
# This file contains a set of csh-like pushd/popd routines for ksh.
# You must be a ksh/bash/etc user and source this file in order to use them.
# The best way to autoload them is to put this file in a directory that's
# on FPATH and make a symlink to it by the name of each function.
###########################################################################

###########################################################################
# pushd/popd/dirs implementation.
# Note: this design allows you to access the first stacked directory
# as $lwd (last working directory) and the n'th one as ${DIRSTACK[n]}.
###########################################################################

if [[ -n "$BASH_VERSION" ]]; then

function pushd
{
    builtin pushd "$@"
    lwd=${DIRSTACK[1]}
}

function popd
{
    builtin popd "$@"
    lwd=${DIRSTACK[1]}
}

else

set -A DIRSTACK -- "${DIRSTACK[@]}"

function dirs
{
    if [[ $# -gt 0 ]]; then
	typeset dir
	typeset -i i=0
	for dir in "$PWD" "${DIRSTACK[@]}"; do
	    printf "%s" "[$i] $dir"
	    i=$((i+1))
	done
    else
	typeset _firstdir=1
	for dir in "$PWD" "${DIRSTACK[@]}"; do
	    if [[ "$dir" = $HOME* ]]; then
		dir=\~${dir#$HOME}
	    fi
	    [[ -n "$_firstdir" ]] || printf " "
	    printf "%s" "$dir"
	    _firstdir=
	done
	unset _firstdir
	printf "\n"
    fi

    lwd=${DIRSTACK[0]}
}

function pushd
{
   typeset _cdto
   typeset -i _num

   case $# in
      (0)
         if [[ -z "$DIRSTACK" ]]; then
            echo "pushd: Error: directory stack empty" >&2
	    set -A DIRSTACK
	    lwd=
            return 1
         else
            _popd
            set -A DIRSTACK -- "$OLDPWD" "${DIRSTACK[@]}"
         fi
         ;;
      (1)
	 case "$@" in
	    (-h)
		echo "Usage:\tpushd new-dir\t(push dir on the stack)" >&2
		echo "   or:\tpushd old new\t(s/old/new/, then push)" >&2
		echo "   or:\tpushd\t\t(toggle top two dirs)" >&2
		echo "   or:\tpushd +n\t(rotate to n'th dir on stack)" >&2
		echo "   or:\tpushd -n\t(pushd n levels up from cwd)" >&2
		return 0
		;;
	    (-[[:digit:]]*)
	       _num=$1
	       typeset _pwd=$PWD
	       while ((_num < 0)); do
		  cd ..
		  let _num=_num+1
	       done
	       set -A DIRSTACK -- "$_pwd" "${DIRSTACK[@]}"
	       ;;
	    (+[[:digit:]]*)
	       _num=${1#+}
	       _num=$((_num-1))
	       _cdto="${DIRSTACK[$_num]}"
	       if [[ -z "$_cdto" ]]; then
		  echo "pushd: Warning: directory stack not that deep" >&2
		  return 1
	       fi
	       cd "$_cdto"
	       unset DIRSTACK[$_num]
	       set -A DIRSTACK -- "$OLDPWD" "${DIRSTACK[@]}"
	       ;;
	    (?*)
	       # Allow leading $ on variables to be elided a la csh.
	       [[ ! -d $1 && "$1" = [A-Za-z_]* ]] && eval _cdto=\$$1
	       cd "${_cdto:-$1}" || return $?
	       # If the new dir is already on the stack pop it out.
	       # No sense keeping multiple copies.
	       typeset _dir
	       set -A _uniq --
	       for _dir in "$OLDPWD" "${DIRSTACK[@]}"; do
		  [[ "$_dir" != "$PWD" ]] || continue
		  set -A _uniq -- "${_uniq[@]}" "$_dir"
	       done
	       set -A DIRSTACK -- "${_uniq[@]}"
	       unset _uniq
	       ;;
	 esac
         ;;
      (2)
	 case "$@" in
	    (-*)
	       echo "pushd: Error: too many arguments" >&2
	       return 1
	       ;;
	    (*)
	       cd "$@" >&- || return $?
	       set -A DIRSTACK -- "$OLDPWD" "${DIRSTACK[@]}"
	       ;;
	 esac
         ;;
      (*)
	 echo "pushd: Error: too many arguments" >&2
	 return 1
         ;;
   esac

   dirs
}

function _popd
{
   typeset -i _num
   if [[ -z "$DIRSTACK" ]]; then
      echo "popd: Error: directory stack empty" >&2
      set -A DIRSTACK
      return 1
   fi
   case "$@" in
      (+[1-9]*)
         _num=${1#+}
	 if [[ $_num -gt ${#DIRSTACK[*]} ]]; then
            echo "popd: Error: directory stack not that deep" >&2
	    return 1
	 fi
	 let _num=_num-1
         DIRSTACK[$_num]=''
	 typeset dir
	 set --
	 for dir in "${DIRSTACK[@]}"; do
	    [[ "$dir" != "" ]] || continue
	    set -- "$@" "$dir"
	 done
         set -A DIRSTACK -- "$@"
         ;;
      (?*)
         echo "popd: Error: illegal argument" >&2
         return 1
         ;;
      (*)
         set "${DIRSTACK[@]}"
         cd "$1"
         shift
         set -A DIRSTACK -- "$@"
         ;;
   esac
}

function popd { _popd "$@" || return 1; dirs; }

fi
