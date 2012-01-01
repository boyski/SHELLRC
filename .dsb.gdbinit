directory ~

set history save on
set history filename ~/.gdb_history

set listsize 20

# Warning, this can shut off other features set to 'auto'.
set confirm off

# Apparently 'ask' mode is now disabled. Must decide "parent|child" advance.
#set follow-fork-mode ask

# New as of 6.1
set breakpoint pending on

# This generates an implicit stop right after shared libs are loaded.
#set stop-on-solib-events 1

# Potentially useful in LD_PRELOAD debugging.
set backtrace past-main on

set print null-stop
set print elements 2048
set print pretty on 

define bp
info break
end

# C++ stuff (http://gcc.gnu.org/ml/libstdc++/2002-02/msg00034.html)
#set print static-members off
#set print object on
#set print static-members on
#set print vtbl on 
#set print demangle on 
#set demangle-style gnu-v3
