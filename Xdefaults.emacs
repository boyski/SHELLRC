
! Pick up standard emacs-style customizations.
#ifdef sun
#  include "/usr/dt/app-defaults/C/UNIXbindings"
#endif

! Enable Alt/Meta key when doing emacs-style cmd-line editing in dtterm.
*DtTerm*kshMode:	True

! Translation table for xterms to map the Meta-<key> chord into an
! ESC-<key> sequence. The Meta key may be marked Alt on some keyboards.
! Everything down to the <Key>End mapping is copied from the
! app-defaults/XTerm file; after that is local setup.
XTerm*VT100*Translations:	#override \
        @Num_Lock<Key>KP_0: string(0)\n\
        @Num_Lock<Key>KP_1: string(1)\n\
        @Num_Lock<Key>KP_2: string(2)\n\
        @Num_Lock<Key>KP_3: string(3)\n\
        @Num_Lock<Key>KP_4: string(4)\n\
        @Num_Lock<Key>KP_5: string(5)\n\
        @Num_Lock<Key>KP_6: string(6)\n\
        @Num_Lock<Key>KP_7: string(7)\n\
        @Num_Lock<Key>KP_8: string(8)\n\
        @Num_Lock<Key>KP_9: string(9)\n\
        @Num_Lock<Key>KP_Add: string(+)\n\
        @Num_Lock<Key>KP_Decimal: string(.)\n\
        @Num_Lock<Key>KP_Divide: string(/)\n\
        @Num_Lock<Key>KP_Enter: string(\015)\n\
        @Num_Lock<Key>KP_Equal: string(=)\n\
        @Num_Lock<Key>KP_Multiply: string(*)\n\
        @Num_Lock<Key>KP_Subtract: string(-)\n\
	<Key>KP_Add: string(+)\n\
        <Key>KP_Divide: string(/)\n\
        <Key>KP_Enter: string(\015)\n\
        <Key>KP_Equal: string(=)\n\
        <Key>KP_Multiply: string(*)\n\
        <Key>KP_Subtract: string(-)\n\
        <Key>Prior:scroll-back(1,page)\n\
        <Key>Next:scroll-forw(1,page)\n\
	<Key>F16: start-extend() select-end(PRIMARY, CUT_BUFFER0, CLIPBOARD) \n\
	<Key>F18: insert-selection(PRIMARY, CLIPBOARD) \n\
	<Key>F27: scroll-back(100,page) \n\
	<Key>R13: scroll-forw(100,page) \n\
	<Key>Home: scroll-back(100,page) \n\
	<Key>End: scroll-forw(100,page) \n\
        Mod1<Key>f	: string(0x1b) string("f")\n\
        Mod1<Key>b	: string(0x1b) string("b")\n\
        Mod1<Key>c	: string(0x1b) string("c")\n\
        Mod1<Key>d	: string(0x1b) string("d")\n\
        Mod1<Key>l	: string(0x1b) string("l")\n\
        Mod1<Key><	: string(0x1b) string("<")\n\
        Mod1<Key>>	: string(0x1b) string(">")\n\
        Mod1<Key>.	: string(0x1b) string(".")\n\
        Mod1<Key>*	: string(0x1b) string("*")

