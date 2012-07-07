#!shell (just so 'file' says the right thing)

# Written by David Boyce ~1995 and placed in the public domain.

# These functions manipulate path variables. A path variable is
# considered to be an exported shell variable whose value is organized
# as a series of potentially null entries (strings) separated by colons.
# I.e:
#      /usr/xxx:/usr/yyy::/usr/zzz:
# is a path value. Note that path entries are generally but not
# necessarily directories, and even if they are conceptually
# directories those directories are not required to exist at a given
# time. Also, note that path vars do not need to be exported but they
# usually are; to keep the code simple these tools assume they are
# to be exported. Last, because it simplifies the usage, we assume
# all path variable names are in upper case. This allows shorthand
# such as "onpath tmp" by eliminating confusion over whether 'tmp'
# is a pathvar or a path entry.

# The offpath() function removes all instances of the specified entry(s)
# from the specified path variable.

# The onpath() function uses offpath() to ensure that the specified
# entries don't occur in the specified path variable, then adds them at
# the front or back or in relative location in the interior, as requested.

# The cleanpath() function removes the 2nd through last instances
# of each entry in the specified path(s). Optionally, it also removes
# entries which do not refer to existing directories.

# The listpath() routine simply prints the path entries to stdout,
# one per line. This is a convenience function. For super convenience
# the command 'path' is aliased to 'listpath'.

# These functions require a modern ksh/bash/etc shell. They use only
# features which are in the older (1988) ksh version, though the
# substitutions could be done much more easily and readably with the
# newer (POSIX) substitution operator.

# They are optimized for the PATH variable but will operate on
# any variable in path format (e.g. MANPATH or LD_LIBRARY_PATH)
# at the (minor) cost of two additional eval statements.

# Note that some path variables, PATH in particular, treat the empty
# string as a synonym for the current directory. These functions
# do not implement that special case; thus you must specify
# the empty string '' to remove a literal empty string and
# '.' to add or remove an entry called '.'.

# Though not documented in the usage msgs, these will also accept no
# more than one compound entry in colon-delimited format. More precisely,
# offpath will take such an entry, separate it, and then
# remove each individually. Onpath doesn't need to treat this case
# specially; it just pastes the entire string to the front or back
# as requested without caring whether it's a single entry or a
# colon-separated list. Note: if the ~ metacharacter is used in the
# interior of a compound entry it may not be expanded correctly.

##########################################################################

if [[ -z "$ECHO" ]]; then
    if [[ -n "$BASH_VERSION" ]]; then
	ECHO="echo -e"
    else
	ECHO="echo"
    fi
fi

function _canonpath
{
    typeset _var _val
    for _var in "$@"; do
	eval _val=\$$_var
	if [[ "$_val" != */* && "$_var" != */ ]]; then
	    :
	elif [[ -d "$_val" ]]; then
	    cd "$_val" && cd "$OLDPWD" && eval $_var=$OLDPWD
	elif [[ -f "$_val" ]]; then
	    typeset _dir=${_val%/*} _base=${_val##*/}
	    cd "$_dir" && cd "$OLDPWD" && eval $_var=$OLDPWD/$_base
	fi
    done
}

##########################################################################

# We allow the -F and -B flags here for consistency but ignore them.
function offpath
{
    typeset entry pth_var pth_tmp new_path elem
    if [[ $# -lt 1 || ( "$1" = -* && "$1" != -[FfBb]* ) ]]; then
	echo 1>&2 "Usage:    offpath [<path-var>] entry ..."
	echo 1>&2 "Examples: offpath MANPATH $HOME/man /usr/local/gnu/man"
	echo 1>&2 "          offpath /usr/local/bin"
	echo
	echo "Removes all occurrences of each specified entry from <path-var>"
	echo "The -F and -B flags are allowed for consistency but have no effect."
	return 1
    fi
    # Assumption: path variables start with capital letters!
    # If first arg doesn't fit assumption, use PATH.
    if [[ "$1" = [A-Z]* ]]; then
	pth_var=$1; shift
    else
	pth_var=PATH
    fi
    # Allow but ignore a flag here for consistency with onpath.
    [[ "$1" = -* ]] && shift
    # Set a temp var to path value, special-casing PATH for performance.
    case "$pth_var" in
	(PATH) pth_tmp="$PATH" ;;
	(*) eval pth_tmp=\$$pth_var ;;
    esac
    # Disambiguate leading/trailing colons
    [[ "$pth_tmp" != :* ]] || pth_tmp=".$pth_tmp"
    [[ "$pth_tmp" != *: ]] || pth_tmp="$pth_tmp."
    # Use colon to delimit fields.
    oldifs="$IFS"
    typeset IFS=:
    # Make sure no patterns in $* match local files
    set -o noglob
    # Separate any entry-lists provided in path format.
    for elem in $pth_tmp; do
	: ${elem:=.}
	for entry in $*; do
	    _canonpath entry
	    if [[ -a "$entry" && ! -d "$entry" && "$entry" = /* ]]; then
		[[ "$elem" != "${entry%/*}" ]] || continue 2
	    fi
	    [[ "$elem" != "$entry" ]] || continue 2
	done
	new_path="${new_path:+$new_path:}$elem"
    done
    IFS=$oldifs
    unset oldifs
    set +o noglob
    # Now set the real variable back to the modified temp value.
    case "$pth_var" in
	(PATH) PATH="$new_path" ;;
	(*) eval $pth_var="$new_path" ;;
    esac
}

##########################################################################

function onpath
{
    typeset entry entries action pth_var pth_tmp mark missing
    if [[ $# -lt 1 || ( "$1" = -* && "$1" != -[FBQq]* ) ]]; then
	echo 1>&2 "Usage:    onpath <path-var> [-Q] -[FB] entry ..."
	echo 1>&2 "          onpath <path-var> [-Q] -[FB]marker entry ..."
	echo 1>&2 "Examples: onpath PATH -F $HOME/bin /usr/sbin"
	echo 1>&2 "          onpath PATH -B/usr/bin /usr/ccs/bin"
	echo 1>&2 "          onpath PATH -Q /opt/SUNWspro/bin"
	echo 1>&2 "          onpath MANPATH $HOME/man:/usr/local/gnu/man"
	echo 1>&2 "          onpath ~/bin /usr/sbin"
	echo
	echo 'Adds directories to search paths. For each specified entry, onpath'
	echo 'will first remove all instances of it from the specified <path-var>'
	echo 'and then add it back to either the front (-F) or back (-B).'
	echo 'Thus it always leaves exactly one instance of the new entry in'
	echo 'the <path-var>. The default is -F. Appending an entry to the'
	echo '-F or -B flag with no intervening whitespace, e.g. -F/usr/bin,'
	echo 'indicates that you want to place the new entry directly in front'
	echo 'or in back of the existing entry.'
	return 1
    fi
    # Assumption: path variables start with capital letters!
    # If first arg doesn't fit assumption, use PATH.
    if [[ "$1" = [A-Z]* ]]; then
	pth_var=$1; shift
    else
	pth_var=PATH
    fi
    while [[ "$1" = -* ]]; do
	case "$1" in
	    (-[FB]*) action=$1 ;;
	    (-[Qq]) missing=1 ;;
	    (-*) echo 1>&2 "onpath: unrecognized flag $1"; return 1 ;;
	esac
	shift
    done
    : ${action:=-F}
    # Get all instances of the specified entries out of the current path.
    offpath $pth_var "$@"
    # Set a temp var to path value, special-casing PATH for performance.
    case "$pth_var" in
	(PATH) pth_tmp="$PATH" ;;
	(*) eval pth_tmp=\$$pth_var ;;
    esac
    # Collect the specified entries into a colon-separated list.
    # If entry is a full file path, assume user meant its containing dir.
    for entry in $*; do
	[[ -z "$missing" || -a "$entry" ]] || continue
	_canonpath entry
	if [[ -a "$entry" && ! -d "$entry" &&
				    "$entry" != *.jar && "$entry" = /* ]]; then
	    entry=${entry%/*}
	fi
	entries="${entries:+$entries:}$entry"
    done
    # Now just add to front or back as requested. If -[FB] is followed
    # immediately by a directory, we try to place the entries immediately
    # before or after that marker directory.
    case "$action" in
	(-[Ff]) pth_tmp=$entries${pth_tmp:+:$pth_tmp} ;;
	(-[Bb]) pth_tmp=${pth_tmp:+$pth_tmp:}$entries ;;
	(-[Ff]*) 
	    mark=${action#-F}
	    pth_tmp=:$pth_tmp:
	    if [[ "$pth_tmp" = "::" ]]; then
		# Marker is only previous entry - just put new entries in path
		pth_tmp=$entries
	    elif [[ "$pth_tmp" != *:$mark:* ]]; then
		# Marker missing - just put new entries at front
		pth_tmp=${pth_tmp%:}
		pth_tmp=$entries$pth_tmp
	    else
		pth_tmp=${pth_tmp%%:$mark:*}:$entries:$mark:${pth_tmp#*:$mark:}
		pth_tmp=${pth_tmp#:}
		pth_tmp=${pth_tmp%:}
	    fi
	    ;;
	(-[Bb]*) 
	    mark=${action#-B}
	    pth_tmp=:$pth_tmp:
	    if [[ "$pth_tmp" = "::" ]]; then
		# Marker is only previous entry - just put new entries in path
		pth_tmp=$entries
	    elif [[ "$pth_tmp" != *:$mark:* ]]; then
		# Marker missing - just put new entries at back
		pth_tmp=${pth_tmp#:}
		pth_tmp=$pth_tmp$entries
	    else
		pth_tmp=${pth_tmp%%:$mark:*}:$mark:$entries:${pth_tmp#*:$mark:}
		pth_tmp=${pth_tmp#:}
		pth_tmp=${pth_tmp%:}
	    fi
	    ;;
    esac
    # Now set the real variable back to the modified temp value.
    case "$pth_var" in
	(PATH) PATH="$pth_tmp" ;;
	(*) eval export $pth_var="$pth_tmp" ;;
    esac
    unset entry entries action pth_var pth_tmp mark missing
}

##########################################################################

function pkguse
{
   typeset base flag abs rel quiet undo
   OPTIND=1
   while getopts ":HhQU" flag; do
      case $flag in
	 ([Hh])
	    echo 1>&2 "Usage:    pkguse [-U] [-F|-B] base ..."
	    echo 1>&2 "Examples: pkguse /opt/rational/clearcase"
	    echo 1>&2 "          pkguse -Q /opt/sybase"
	    echo 1>&2 "Description:"
	    echo 1>&2 "	  Takes the base of a package, e.g. /opt/SUNWtcx, and"
	    echo 1>&2 "	  adds the appropriate dirs to PATH and MANPATH."
	    echo 1>&2 "	  Use -L to add .../lib to LD_LIBRARY_PATH."
	    echo 1>&2 "	  Warnings for nonexistent dirs are suppressed by -Q."
	    echo 1>&2 "	  Any -F or -B flags are passed on to onpath."
	    echo
	    echo 'Takes a base directory, such as /opt/FSFgdb, and runs onpath()'
	    echo 'multiple times to add the appropriate subdirs to PATH, MANPATH, etc.'
	    echo 'Flags which are recognized by onpath/offpath are passed along unmodified.'
	    return 1
	    ;;
	 ([Q]) quiet=SET ;;
	 ([U]) undo=SET ;;
	 (\?) OPTIND=$((OPTIND-1)); break ;; # a -F or -B flag was hit
      esac
   done
   shift $((OPTIND-1))

   if [[ "$1" = -* ]]; then
      if [[ "$1" = */* ]]; then
	 rel="$1"
      else
	 abs="$1"
      fi
      shift
      if [[ "$1" = -* ]]; then
	 echo 1>&2 "Error: unrecognized option: $1"
	 return 1
      fi
   fi

   for base in "$@"; do
      if [[ -z "$undo" ]]; then
	 if [[ -d $base/bin ]]; then
	    onpath PATH ${abs:-${rel:+$rel/bin}} $base/bin
	 elif [[ -z "$quiet" ]]; then
	    echo 1>&2 "Warning: $base/bin: no such directory"
	 fi
	 if [[ -d $base/man ]]; then
	    onpath MANPATH ${abs:-${rel:+$rel/man}} $base/man
	 elif [[ -d $base/share/man ]]; then
	    onpath MANPATH ${abs:-${rel:+$rel/man}} $base/share/man
	 elif [[ -d $base/doc/man ]]; then
	    onpath MANPATH ${abs:-${rel:+$rel/man}} $base/doc/man
	 elif [[ -z "$quiet" ]]; then
	    echo 1>&2 "Warning: $base/man: no such directory"
	 fi
      else
	 offpath PATH $base/bin
	 offpath MANPATH $base/man $base/doc/man
	 offpath LD_LIBRARY_PATH $base/lib
      fi
   done
   unset base flag abs rel quiet undo
}

##########################################################################

function cleanpath
{
   typeset entry oldifs pth_var old_path new_path prev testdirs
   typeset nmode verbose flag
   OPTIND=1
   while getopts "HhNTV" flag; do
      case $flag in
	 ([Hh]|\?)
	    echo 1>&2 "Usage: cleanpath [-NTV] [<path-var> ...]"
	    echo 1>&2 "cleanpath -N doesn't actually change anything"
	    echo 1>&2 "cleanpath -T also removes entries which don't exist"
	    echo 1>&2 "cleanpath -V shows entries removed"
	    echo 1>&2 "<path-var> defaults to PATH"
	    echo 1>&2 "Examples: cleanpath (cleans PATH)"
	    echo 1>&2 "          cleanpath -N (shows doubled entries in PATH)"
	    echo 1>&2 "          cleanpath MANPATH (cleans MANPATH)"
	    echo 1>&2 "          cleanpath -T LD_LIBRARY_PATH LD_RUN_PATH"
	    echo
	    echo 'Removes redundant entries from a given list of path variables,'
	    echo 'default PATH. The -T flag causes entries that do not exist'
	    echo 'to be removed as well, and -V prints any entries removed.'
	    echo 'The -N flag shows what it would do without doing anything.'
	    return 1
	    ;;
	 ([N]) nmode=1 verbose=1 ;;
	 ([V]) verbose=1 ;;
	 ([T]) testdirs=1 ;;
      esac
   done
   shift $((OPTIND-1))

   # Loop through specified path variables, defaulting to PATH.
   for pth_var in ${*:-PATH}; do
      # Set a temp var to path value, special-casing PATH for performance.
      # Add artificial leading and trailing colons for regularity of syntax.
      case "$pth_var" in
	 (PATH) old_path=":$PATH:" ;;
	 (*) eval old_path=:\$$pth_var: ;;
      esac
      # Skip paths which are unset
      [[ "$old_path" = "::" ]] && continue
      # Turn all instances of "::" into ":.:".
      while [[ "$old_path" = *::* ]]; do
	 old_path=${old_path%%::*}:.:${old_path#*::}
      done
      # Place the entries in old_path into $*
      oldifs="$IFS"
      IFS=:
      set -- $old_path
      IFS=$oldifs
      # Now walk through $*, placing all previously-unseen entries back
      # into the new path variable. We remember each entry on the 'seen'
      # list as we encounter it for subsequent rejection. If testdirs
      # is set, we remove entries if they don't exist as directories.
      if [[ -n "$BASH_VERSION" ]]; then
	  declare -a seen
      else
	  set -A seen
      fi
      unset new_path
      for entry in $*; do
	 for prev in ${seen[*]}; do
	    if [[ "$entry" = "$prev" ]]; then
	       if [[ -n "$verbose" ]]; then
		  echo 1>&2 "Removing redundant entry: $entry"
	       fi
	       continue 2
	    fi
	 done
	 seen[${#seen[@]}]=$entry
	 if [[ -n "$testdirs" && ! -a $entry ]]; then
	    if [[ -n "$verbose" ]]; then
	       echo 1>&2 "Removing nonexistent entry: $entry"
	    fi
	    continue
	 fi
	 new_path="${new_path:+$new_path:}$entry"
      done
      unset seen entry prev
      # Now set the real variable back to the modified temp value.
      if [[ -z "$nmode" ]]; then
	 case "$pth_var" in
	    (PATH) PATH="$new_path" ;;
	    (*) eval $pth_var="$new_path" ;;
	 esac
      fi
   done
}

##########################################################################

function listpath
{
    typeset entry pth_var pth_tmp oldifs
    if [[ "$1" = -[Hh] ]]; then
	echo 1>&2 "Usage: listpath [<path-var>]"
	echo
	echo 'Prints the entries of the specified path variable (default: PATH)'
	echo 'to stdout, one per line.'
	return 1
    fi
    pth_var=${1:-PATH}
    case "$pth_var" in
	(PATH) pth_tmp="$PATH" ;;
	(*) eval pth_tmp=\$$pth_var ;;
    esac
    oldifs="$IFS"
    IFS=:
    for entry in $pth_tmp; do
	echo "${entry:-.}"
    done
    IFS=$oldifs
    if [[ "$pth_tmp" = *: ]]; then
	echo "."
    fi
}
alias path=listpath
