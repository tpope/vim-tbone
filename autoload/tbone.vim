" autoload/tbone.vim
" Maintainer:   Tim Pope <http://tpo.pe/>

if exists('g:autoloaded_tbone') || v:version < 700 || &compatible
  finish
endif
let g:autoloaded_tbone = 1

" Section: Sessions

function! tbone#session(...) abort
  if a:0 && a:1 =~# '^.\+:'
    return matchstr(a:1, '[^:]*')
  elseif exists('g:tmux_session')
    return g:tmux_session
  else
    return ''
  endif
endfunction

function! tbone#qualify(target) abort
  let target = substitute(a:target, "\n$", '', '')
  if target =~# '^:'
    return get(g:, 'tmux_session', '') . target
  elseif target =~# '^\%([^$!]\|[+-]\d*\|{.*}\)$'
    return get(g:, 'tmux_session', '') . ':.' . target
  elseif target =~# ':' || target =~# '^%' || !exists('g:tmux_session')
    return target
  else
    return g:tmux_session . ':' . target
  endif
endfunction

" Section: Completion

function! s:fnameescape(string) abort
  if type(a:string) ==# type([])
    return map(copy(a:string), 's:fnameescape(v:val)')
  elseif exists('*fnameescape')
    return fnameescape(a:string)
  elseif a:string ==# '-'
    return '\-'
  else
    return substitute(escape(a:string," \t\n*?[{`$\\%#'\"|!<"),'^[+>]','\\&','')
  endif
endfunction

function! s:systemarg(cmd) abort
  if exists('*systemlist')
    let results = systemlist(a:cmd)
  else
    let results = split(system(a:cmd), "\n")
  endif
  return join(s:fnameescape(results), "\n")
endfunction

function! tbone#complete_sessions(...) abort
  return s:systemarg('tmux list-sessions -F "#S"')
endfunction

function! tbone#complete_windows(...) abort
  return s:systemarg('tmux list-windows -F "#W" -t '.shellescape(tbone#session())) . "\n" .
        \s:systemarg('tmux list-windows -F "#S:#W" -a') .
        \ "\n^\n$\n!\n+\n-\n{start}\n{end}\n{last}\n{next}\n{previous}"
endfunction

function! tbone#complete_panes(...) abort
  return s:systemarg('tmux list-panes -F "#W.#P" -s -t '.shellescape(tbone#session())) . "\n" .
        \s:systemarg('tmux list-panes -F "#S:#W.#P" -a') .
        \ "\n!\n+\n-\n{last}\n{next}\n{previous}" .
        \ "\n{top}\n{bottom}\n{left}\n{right}" .
        \ "\n{top-left}\n{top-right}\n{bottom-left}\n{bottom-right}" .
        \ "\n{up-of}\n{down-of}\n{left-of}\n{right-of}"
endfunction

function! tbone#complete_clients(...) abort
  return s:systemarg('tmux list-clients -F "#{client_tty}"')
endfunction

function! tbone#complete_buffers(...) abort
  return s:systemarg('tmux list-buffers -F "#{buffer_name}"')
endfunction

function! tbone#complete_executable(lead, ...) abort
  let executables = []
  for dir in split($PATH, ':')
    let executables += map(split(glob(dir.'/'.a:lead.'*'), "\n"), 'v:val[strlen(dir)+1 : -1]')
  endfor
  call sort(executables)
  let seen = {}
  let completions = ''
  for entry in executables
    if !has_key(seen, entry)
      let seen[entry] = 1
      let completions .= entry . "\n"
    endif
  endfor
  return completions
endfunction

" Stolen from the zsh tab completion
let s:aliases = {
      \ 'attach':      'attach-session',
      \ 'detach':      'detach-client',
      \ 'has':         'has-session',
      \ 'lsc':         'list-clients',
      \ 'lscm':        'list-commands',
      \ 'ls':          'list-sessions',
      \ 'new':         'new-session',
      \ 'refresh':     'refresh-client',
      \ 'rename':      'rename-session',
      \ 'showmsgs':    'show-messages',
      \ 'source':      'source-file',
      \ 'start':       'start-server',
      \ 'suspendc':    'suspend-client',
      \ 'switchc':     'switch-client',
      \
      \ 'breakp':      'break-pane',
      \ 'capturep':    'capture-pane',
      \ 'displayp':    'display-panes',
      \ 'downp':       'down-pane',
      \ 'findw':       'find-window',
      \ 'joinp':       'join-pane',
      \ 'killp':       'kill-pane',
      \ 'killw':       'kill-window',
      \ 'last':        'last-window',
      \ 'linkw':       'link-window',
      \ 'lsp':         'list-panes',
      \ 'lsw':         'list-windows',
      \ 'movew':       'move-window',
      \ 'neww':        'new-window',
      \ 'nextl':       'next-layout',
      \ 'next':        'next-window',
      \ 'pipep':       'pipe-pane',
      \ 'prev':        'previous-window',
      \ 'renamew':     'rename-window',
      \ 'resizep':     'resize-pane',
      \ 'respawnw':    'respawn-window',
      \ 'rotatew':     'rotate-window',
      \ 'selectl':     'select-layout',
      \ 'selectp':     'select-pane',
      \ 'selectw':     'select-window',
      \ 'splitw':      'split-window',
      \ 'swapp':       'swap-pane',
      \ 'swapw':       'swap-window',
      \ 'unlinkw':     'unlink-window',
      \ 'upp':         'up-pane',
      \
      \ 'bind':        'bind-key',
      \ 'lsk':         'list-keys',
      \ 'send':        'send-keys',
      \ 'unbind':      'unbind-key',
      \
      \ 'set':         'set-option',
      \ 'setw':        'set-window-option',
      \ 'show':        'show-options',
      \ 'showw':       'show-window-options',
      \
      \ 'setenv':      'set-environment',
      \ 'showenv':     'show-environment',
      \
      \ 'confirm':     'confirm-before',
      \ 'display':     'display-message',
      \
      \ 'clearhist':   'clear-history',
      \ 'copyb':       'copy-buffer',
      \ 'deleteb':     'delete-buffer',
      \ 'lsb':         'list-buffers',
      \ 'loadb':       'load-buffer',
      \ 'pasteb':      'paste-buffer',
      \ 'saveb':       'save-buffer',
      \ 'setb':        'set-buffer',
      \ 'showb':       'show-buffer',
      \
      \ 'if':          'if-shell',
      \ 'lock':        'lock-server',
      \ 'run':         'run-shell',
      \ 'info':        'server-info',
      \ }

unlet! s:commands
function! s:commands() abort
  if !exists('s:commands')
    let lines = split(system('tmux list-commands'), "\n")
    if v:shell_error
      return {}
    endif
    let s:commands = {}
    for line in lines
      if line =~# '^\S\+ (\S\+)'
        let s:aliases[matchstr(line, ' (\zs\S\+\ze)')] = matchstr(line, '^\S\+')
        let line = substitute(line, ' (\S\+)', '', '')
      endif
      let s:commands[matchstr(line, '^\S\+')] = matchstr(line, '\s\zs\S.*')
    endfor
  endif
  return s:commands
endfunction

function! tbone#complete_command(A, L, P) abort
  let pre = a:L[0 : a:P-1]
  let cmd = matchstr(pre, '\S*\s\+\zs\(\S\+\)\ze\s')
  if cmd ==# ''
    return join(sort(keys(s:commands()) + keys(s:aliases)), "\n")
  endif
  let signature = get(s:commands(), get(s:aliases, cmd, cmd), '')
  if a:L =~# '\s-$'
    let options = join(map(split(signature, ' '), 'matchstr(v:val, "^\\[-\\zs\\w\\+")'), '')
    return join(map(split(options, '\zs'), '"-".v:val'), "\n")
  endif
  let flag = matchstr(pre, '.*\zs-\w\ze\s\+\S*$')
  let type = matchstr(signature, '\['.flag.' \zs.\{-\}\ze\]')
  if !empty(type)
    let complete = ''
    if type =~# '-session'
      let complete .= tbone#complete_sessions()
    endif
    if type =~# '-window'
      let complete .= tbone#complete_windows()
    endif
    if type =~# '-pane'
      let complete .= tbone#complete_panes()
    endif
    if type =~# '-client'
      let complete .= tbone#complete_clients()
    endif
    if type =~# 'buffer-index'
      let complete .= tbone#complete_buffers()
    endif
    if type =~# 'key-table'
      let complete .= "vi-edit\nemacs-edit\nvi-choice\nemacs-choice\nvi-copy\nemacs-copy\n"
    endif
    return complete
  endif
  let bare = substitute(signature, '\[-.\{-\}\] \=', '', 'g')
  if bare =~# 'command'
    return tbone#complete_executable(a:A)
  elseif bare =~# 'template'
    return join(sort(keys(s:commands()) + keys(s:aliases)), "\n")
  endif
  return ''
endfunction

" Section: :Tattach

function! tbone#attach_command(...) abort
  let has_session = a:0 && empty(system('tmux has-session -t '.shellescape(a:1)))
  if !a:0
    unlet! g:tmux_session
    echo 'Using default tmux session'
    return ''
  elseif empty(system('tmux has-session -t '.shellescape(a:1)))
    echo 'Using tmux session "'.a:1.'"'
  else
    echohl WarningMsg
    echo 'Warning: tmux session "'.a:1.'" does not exist'
    echohl NONE
  endif
  let g:tmux_session = a:1
  return ''
endfunction

" Section: :Tmux

function! tbone#mux_command(args) abort
  let cmd = matchstr(a:args, '^\S\+')
  let rest = matchstr(a:args, '\s.*')
  if exists('g:tmux_session')
    let signature = get(s:commands(), get(s:aliases, cmd, cmd), '')
    if signature =~# '\[-t target-session\]' && rest !~# '\s-[at]'
      let cmd .= ' -t '.g:tmux_session
    elseif signature =~# '\[-\w*s\w*]' && signature =~# '\[-t target' && rest !~# '\s-[at]'
      let cmd .= ' -s -t '.g:tmux_session
    endif
  endif
  let output = system('tmux ' . cmd . rest)
  echo output
  return ''
endfunction

" Section: :Tput, :Tyank

function! tbone#buffer_command(label, before, command, after, ...) abort
  let tempfile = tempname()
  try
    if !empty(a:before)
      exe a:before tempfile
    endif
    let error = system('tmux ' . a:command . (a:0 ? ' -b ' . shellescape(a:1) : '') . ' ' . tempfile)
    if v:shell_error
      return 'echoerr '.string(error[0:-2])
    endif
    if !empty(a:after)
      exe a:after tempfile
    endif
  finally
    call delete(tempfile)
  endtry
  return ''
endfunction

" Section: :Twrite

" Convert a target pane to an unchanging pane id.  Returns an empty string if
" the pane does not exist.
function! tbone#pane_id(target) abort
  if a:target =~# '^%'
    return index(split(system('tmux list-panes -a -F "#{pane_id}"'), "\n"), a:target) < 0 ?  '' : a:target
  endif
  let target = tbone#qualify(a:target)
  if target =~# '\.last'
    let window = matchstr(target, '.*\ze[.]')
    let output = system(
          \ 'tmux select-pane -t '.shellescape(window).' -l' .
          \  ' \; list-panes -t '.shellescape(window).' -F "#{pane_id} #{pane_active}"' .
          \  ' \; select-pane -t '.shellescape(window).' -l')
    return matchstr(output, '%\d\+\ze 1\>')
  endif
  let target = system('tmux display-message -p -t '.shellescape(target).' "#S:#I.#P"')[0:-2]
  if v:shell_error || target !~# ':.*\.'
    return ''
  endif
  let window = matchstr(target, '.*\ze[.]')
  let offset = matchstr(target, '[0-9+-]\d*$')
  let output = system('tmux list-panes -t '.shellescape(window).' -F "#{pane_id} #P"')
  return matchstr(output, '%\d\+\ze '.offset.'\>')
endfunction

function! tbone#write_command(bang, line1, line2, count, ...) abort
  let target = a:0 ? a:1 : get(g:, 'tbone_write_pane', '')
  if empty(target)
    return 'echoerr '.string('Target pane required')
  endif

  let keys = join(map(
        \ getline(a:line1, a:line2),
        \ 'substitute(v:val,"^\\s*","","")'),
        \ "\r")
  if a:count > 0
    let keys = get(g:, 'tbone_write_initialization', '').keys."\r"
  endif

  try
    let pane_id = tbone#send_keys(target, keys)
    let g:tbone_write_pane = pane_id
    echo len(keys).' keys sent to '.pane_id
    return ''
  catch /.*/
    return 'echoerr '.string(v:exception)
  endtry
endfunction

function! tbone#send_keys(target, keys) abort
  if empty(a:target)
    throw 'Target pane required'
  endif

  let pane_id = tbone#pane_id(a:target)
  if empty(pane_id)
    throw "Can't find pane ".a:target
  elseif pane_id ==# $TMUX_PANE && !has('gui_running')
    throw 'Refusing to write to own tmux pane'
  endif

  if len(a:keys) > 1000
    let temp = tempname()
    call writefile(split(a:keys, "\r", 1), temp, 'b')
    let out = system('tmux load-buffer '.temp.' \; paste-buffer -d -t '.pane_id)
  else
    let out = system('tmux send-keys -t '.pane_id.' "" '.shellescape(a:keys))
  endif

  if v:shell_error
    throw 'tmux: '.out[0:-2]
  endif

  return pane_id
endfunction
