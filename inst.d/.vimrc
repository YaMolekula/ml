set nocompatible
filetype off

set rtp+=/usr/share/vim/bundle/Vundle.vim
call vundle#begin('/usr/share/vim/bundle')

Plugin 'VundleVim/Vundle.vim'
Plugin 'nsf/gocode', {'rtp': 'vim/'}
Plugin 'Valloric/YouCompleteMe'
"Plugin 'davidhalter/jedi-vim'
Plugin 'jalvesaq/Nvim-R'
call vundle#end()
filetype plugin indent on

"let g:ycm_python_binary_path="/opt/conda/bin/python3"
"let g:ycm_global_ycm_extra_conf="/usr/share/vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py"
"let g:ycm_filetype_specific_completion_to_disable = {
      \   'python': 1,
      \ }
au BufRead,BufNewFile *.rs set filetype=rust
"au BufRead,BufNewFile *.r set filetype=R
set encoding=utf-8
