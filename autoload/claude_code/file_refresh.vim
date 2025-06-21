" File refresh functionality for claude-code.vim
" This module provides file refresh functionality to detect and reload files
" that have been modified by Claude Code or other external processes.

" Timer for checking file changes
let s:refresh_timer = v:null

" Setup autocommands for file change detection
" @param claude_code dict The main plugin module
" @param config dict The plugin configuration
function! claude_code#file_refresh#setup(claude_code, config) abort
  if !a:config.refresh.enable
    return
  endif

  " Create autocommand group
  augroup ClaudeCodeFileRefresh
    autocmd!
    
    " Create an autocommand that checks for file changes more frequently
    autocmd CursorHold,CursorHoldI,FocusGained,BufEnter,InsertLeave,TextChanged,TermLeave,TermEnter,BufWinEnter *
      \ if filereadable(expand('%')) | checktime | endif

    " Create an autocommand that notifies when a file has been changed externally
    if a:config.refresh.show_notifications
      autocmd FileChangedShellPost * echomsg 'File changed on disk. Buffer reloaded.'
    endif

    " When Claude Code opens, set a shorter updatetime
    autocmd TermOpen * call s:on_term_open(a:claude_code, a:config)

    " When Claude Code closes, restore normal updatetime  
    autocmd TermClose * call s:on_term_close(a:claude_code)
  augroup END

  " Clean up any existing timer
  call claude_code#file_refresh#cleanup()

  " Create a timer to check for file changes periodically
  let s:refresh_timer = timer_start(
    \ a:config.refresh.timer_interval,
    \ function('s:refresh_timer_callback', [a:claude_code]),
    \ {'repeat': -1}
    \ )

  " Set a shorter updatetime while Claude Code is open
  let a:claude_code.claude_code.saved_updatetime = &updatetime
endfunction

" Timer callback function
function! s:refresh_timer_callback(claude_code, timer_id) abort
  " Only check time if there's an active Claude Code terminal
  let l:current_instance = a:claude_code.claude_code.current_instance
  let l:bufnr = l:current_instance != v:null && has_key(a:claude_code.claude_code.instances, l:current_instance)
    \ ? a:claude_code.claude_code.instances[l:current_instance] : v:null
  
  if l:bufnr != v:null && bufexists(l:bufnr) && !empty(win_findbuf(l:bufnr))
    silent! checktime
  endif
endfunction

" Handle TermOpen event
function! s:on_term_open(claude_code, config) abort
  let l:buf = bufnr('%')
  let l:buf_name = bufname(l:buf)
  
  if l:buf_name =~ 'claude-code$'
    let a:claude_code.claude_code.saved_updatetime = &updatetime
    let &updatetime = a:config.refresh.updatetime
  endif
endfunction

" Handle TermClose event
function! s:on_term_close(claude_code) abort
  let l:buf_name = bufname(0)
  
  if l:buf_name =~ 'claude-code$'
    let &updatetime = a:claude_code.claude_code.saved_updatetime
  endif
endfunction

" Clean up the file refresh functionality (stop the timer)
function! claude_code#file_refresh#cleanup() abort
  if s:refresh_timer != v:null
    call timer_stop(s:refresh_timer)
    let s:refresh_timer = v:null
  endif
endfunction