## export VISUAL=emacs
# Apparently some platforms (SuSE Linux) set this to 'emacs' by default.
unset VISUAL

# The generic profile file.
SHELLRC=${SHELLRC:-/home/.SHELLRC}; export SHELLRC
. ${SHELLRC?}/Profile

#onpath PERL5LIB ~/lib/perl5 ~/lib/perl5/site_perl
if [ -d /opt/local/perl5 ]; then
    onpath PERL5LIB /opt/local/perl5/lib/site_perl
fi

export CLEARCASE_MAKE_COMPAT=gnu

export PERLDB_OPTS="warnLevel=0"

export AODEVELOPER=1

# For help in testing SW, prints file:line in putil error msgs.
export PUTIL_SRCDBG=1

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
    # Apparently needed on Linux due to differing defaults (boo).
    ulimit -c 32768
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

onpath -B /opt/ant/bin

# On Solaris, CSW stuff tends to be newer than bundled SFW.
pkguse -Q -B /opt/csw /opt/sfw

# Some platforms use one of these variants for gcc:
pkguse -Q /opt/csw/gcc3
pkguse -Q /opt/csw/gcc4
pkguse -Q /opt/gcc3
pkguse -Q /opt/dynbin

pkguse -Q /opt/SUNWspro

onpath MANPATH -B ~/$CPU/man

set +o noglob

[[ -z "$DISPLAY" ]] || xtitlebar "$HOSTNAME $$"
