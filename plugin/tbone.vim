" tbone.vim - tmux basics
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.1

if !has('gui_running') && $TERM =~# '^\%(screen\|tmux\)' && empty(&t_ts)
  " enable window title
  let &t_ts = "\e]2;"
  let &t_fs = "\007"
endif

if exists("g:loaded_tbone") || v:version < 700 || &cp || !executable('tmux')
  finish
endif
let g:loaded_tbone = 1

command! -bar -bang -nargs=? -complete=custom,tbone#complete_sessions Tattach
      \ execute tbone#attach_command(<q-args>)
command! -bar -bang -nargs=? -complete=custom,tbone#complete_command Tmux
      \ execute tbone#mux_command(<q-args>)
command! -bar -bang -nargs=? -complete=custom,tbone#complete_buffers -range=0 Tput
      \ execute tbone#buffer_command('Tput', <q-args>, '', 'save-buffer', (<line1>-<bang>0).'read')
command! -bar -bang -nargs=? -complete=custom,tbone#complete_buffers -range Tyank
      \ execute tbone#buffer_command('Tyank', <q-args>, 'silent <line1>,<line2>write', 'load-buffer', '')
command! -bar -bang -nargs=? -range -complete=custom,tbone#complete_panes Twrite
      \ execute tbone#write_command(<bang>0, <line1>, <line2>, <count>, <q-args>)

augroup tbone_reign_supreme_over_tmux_command
  autocmd!
  autocmd VimEnter *
        \ command! -bar -bang -nargs=? -complete=custom,tbone#complete_command Tmux
        \       execute tbone#mux_command(<q-args>)
augroup END
