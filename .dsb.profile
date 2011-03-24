if [[ -f /tools/bin/common.profile ]]; then
    . /tools/bin/common.profile
fi

# Bash doesn't do this by default for login shells.
. ~/.bashrc

# Setup Terminal
#stty erase "^H" kill "^U" intr "^C" eof "^D" susp "^Z" 
#stty hupcl ixon ixoff tostop tabs	

# Apparently some platforms (SuSE Linux) set this to 'emacs' by default.
unset VISUAL

# The generic profile file.
SHELLRC=${SHELLRC:-$HOME/SHELLRC}; export SHELLRC
. ${SHELLRC?}/Profile

if [[ -x /usr/bin/sun ]]; then
    ##### SOLARIS
    pkguse -Q -B /opt/samba
    pkguse -Q /opt/perl-5.8.0-gcc
    #onpath -F/usr/xpg4/bin /opt/local/bin
    export TERMINFO=~/.terminfo
    if [[ -e /opt/java ]]; then
	export JAVA_HOME=/opt/java
    else
	export JAVA_HOME=/usr/java
    fi
    pkguse -Q $JAVA_HOME
elif [[ -e /proc/cpuinfo ]]; then
    ##### LINUX
    # Apparently _was_ needed on Linux due to differing defaults
    # but no longer required or allowed with newer bash versions.
    #ulimit -c 32768
    # GNU ls has an irritating difference in -l format without this.
    export LC_TIME=C
    #[[ "$TERM" != "xterm" ]] || TERM=xterm-r6
    [[ "$TERM" != "xterm" ]] || export TERMINFO=~/.terminfo TERM=xterm-r6
    if [[ -e /opt/java ]]; then
	export JAVA_HOME=/opt/java
	onpath $JAVA_HOME/bin
    fi
    #onpath /opt/local/bin
elif [[ -d /cores ]]; then
    ##### MAC OS X
    ulimit -c unlimited
fi

#onpath -B /opt/ant/bin

# On Solaris, CSW stuff tends to be newer than bundled SFW.
#pkguse -Q -B /opt/csw /opt/sfw

# Xcode stuff seems to be here on Mac OS X.
pkguse -Q /Developer/usr

# Some platforms use one of these variants for gcc:
#pkguse -Q /opt/csw/gcc3
#pkguse -Q /opt/csw/gcc4
#pkguse -Q /opt/gcc3
#pkguse -Q /opt/dynbin

#pkguse -Q /opt/SUNWspro

onpath MANPATH -B ~/$CPU/man

set +o noglob

[[ -z "$DISPLAY" ]] || xtitlebar "$HOSTNAME $$"

## Broadcom stuff

onpath ~/$CPU/bin ~/bin /projects/hnd/tools/linux-$(uname -r)/bin /projects/hnd/tools/linux/hndtools-mipsel-uclibc/bin /projects/hnd/tools/linux/hndtools-mipsel-linux/bin /projects/hnd/tools/linux/bin /projects/hnd/tools/precommit/bin /tools/bin /usr/local/bin
