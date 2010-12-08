" This file is provided under the RUMPL, the Render Unto Me Public License,
" which states that if you make any changes or extensions which could
" reasonably be considered improvements, you have a moral - but not a
" legal - obligation to send them back to the author, David Boyce,
" <dsb (at) boyski.com>.
"
" Typically reasonable/standard vi settings.
set ai redraw sm aw sw=4 tabstop=8 report=1
"
syntax off
set nohlsearch
"
" Personal preference.
set shell=/bin/ksh
"
" Avoids a screwy "feature" added in VIM 7.
let loaded_matchparen = 1
"
" Request no sounds.
set vb t_vb=
"
set shortmess+=r
set autoindent
set smartindent
"
set nobackup nowritebackup
set ff=unix
"
:map <F5> V%zf
"
" Bind the + key to a macro which reformats the current text paragraph.
map + {!}fmt -w 68}
"
" Bind *Q to a macro which quotes the text by prepending "> ".
map *Q :.,$s?^?> ?
"
" Bind *U to a macro which undoes the work of *Q.
map *U :.,$s?^> ??
"
" Bind Q to W, since the only reason I know of for hitting Q is a
" finger fumble while trying to hit W.
map Q W
"
" Let the user set shiftwidth to 'n' by typing '*n'.
map *2 :set sw=2
map *3 :set sw=3
map *4 :set sw=4
map *8 :set sw=8
"
" And similarly allow reformatting (of C-style code) via '**n'.
map **2 :%!indent -i2
map **3 :%!indent -i3
map **4 :%!indent -i4
map **8 :%!indent -i8
"
" Macros for navigating ClearCase version trees within the editor.
"
" Show the output of 'ct diff -pred' within the vi buffer
map *D :!cleartool diff -pred -ser % \|\|:
" Go to the /main/LATEST version of your file.
map *ML :e `cleartool desc -fmt \%En %`@@/main/LATEST
" Go to the previous version
map *P :e `cleartool desc -fmt \%En@@\%PVn %`
" Checkpoint the current buffer (check in then out)
map *B :!cleartool ci % && cleartool co %
" Return to the selected (by the config spec) version
map *S :e `cleartool desc -fmt \%En %`
"
autocmd BufRead *.java set makeprg=ant
autocmd BufRead *.java set efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,
	\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
