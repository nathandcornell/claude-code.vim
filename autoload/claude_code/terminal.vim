" Terminal management for claude-code.vim
" This module provides terminal buffer management for claude-code.vim.
" It handles creating, toggling, and managing the terminal window.

" Initialize terminal management structure
let s:terminal = {
  \ 'instances': {},
  \ 'saved_updatetime': v:null,
  \ 'current_instance': v:null,
  \ }

" Get the current git root or a fallback identifier
" @param git dict The git module functions
" @return string identifier Git root path or fallback identifier
function! s:get_instance_identifier(git) abort
  let l:git_root = claude_code#git#get_git_root()
  if l:git_root != v:null
    return l:git_root
  else
    " Fallback to current working directory if not in a git repo
    return getcwd()
  endif
endfunction

" Create a split window according to the specified position configuration
" @param position string Window position configuration
" @param config dict Plugin configuration containing window settings
" @param existing_bufnr number|v:null Buffer number of existing buffer to show in the split (optional)
function! s:create_split(position, config, existing_bufnr) abort
  let l:is_vertical = a:position =~# 'vsplit\|vertical'

  " Create the window with the user's specified command
  " If the command already contains 'split' or 'vsplit', use it as is
  if a:position =~# 'split'
    execute a:position
  else
    " Otherwise append 'split'
    execute a:position . ' split'
  endif

  " If we have an existing buffer to display, switch to it
  if a:existing_bufnr != v:null
    execute 'buffer ' . a:existing_bufnr
  endif

  " Resize the window appropriately based on split type
  if l:is_vertical
    execute 'vertical resize ' . float2nr(&columns * a:config.window.split_ratio)
  else
    execute 'resize ' . float2nr(&lines * a:config.window.split_ratio)
  endif
endfunction

" Get the terminal management structure
function! claude_code#terminal#get_terminal() abort
  return s:terminal
endfunction

" Set up function to force insert mode when entering the Claude Code window
" @param claude_code dict The main plugin module
" @param config dict The plugin configuration
function! claude_code#terminal#force_insert_mode(claude_code, config) abort
  let l:current_bufnr = bufnr('%')

  " Check if current buffer is any of our Claude instances
  let l:is_claude_instance = v:false
  for l:bufnr in values(a:claude_code.claude_code.instances)
    if l:bufnr != v:null && l:bufnr == l:current_bufnr && bufexists(l:bufnr)
      let l:is_claude_instance = v:true
      break
    endif
  endfor

  if l:is_claude_instance
    " Only enter insert mode if we're in the terminal buffer and not already in insert mode
    " and not configured to stay in normal mode
    if a:config.window.start_in_normal_mode
      return
    endif

    let l:mode = mode()
    if &buftype ==# 'terminal' && l:mode !=# 't' && l:mode !=# 'i'
      silent! stopinsert
      " Use timer to schedule the startinsert (similar to vim.schedule)
      call timer_start(0, {-> execute('silent! startinsert')})
    endif
  endif
endfunction

" Toggle the Claude Code terminal window
" @param claude_code dict The main plugin module
" @param config dict The plugin configuration
" @param git dict The git module functions
function! claude_code#terminal#toggle(claude_code, config, git) abort
  " Determine instance ID based on config
  let l:instance_id = ''
  if a:config.git.multi_instance
    if a:config.git.use_git_root
      let l:instance_id = s:get_instance_identifier(a:git)
    else
      let l:instance_id = getcwd()
    endif
  else
    " Use a fixed ID for single instance mode
    let l:instance_id = 'global'
  endif

  let a:claude_code.claude_code.current_instance = l:instance_id

  " Check if this Claude Code instance is already running
  let l:bufnr = get(a:claude_code.claude_code.instances, l:instance_id, v:null)
  if l:bufnr != v:null && bufexists(l:bufnr)
    " Check if there's a window displaying this Claude Code buffer
    let l:win_ids = win_findbuf(l:bufnr)
    if len(l:win_ids) > 0
      " Claude Code is visible, close the window
      for l:win_id in l:win_ids
        execute 'close ' . win_id2win(l:win_id)
      endfor
    else
      " Claude Code buffer exists but is not visible, open it in a split
      call s:create_split(a:config.window.position, a:config, l:bufnr)
      " Force insert mode more aggressively unless configured to start in normal mode
      if !a:config.window.start_in_normal_mode
        call timer_start(0, {-> execute('stopinsert | startinsert')})
      endif
    endif
  else
    " Prune invalid buffer entries
    if l:bufnr != v:null && !bufexists(l:bufnr)
      let a:claude_code.claude_code.instances[l:instance_id] = v:null
    endif
    
    " This Claude Code instance is not running, start it in a new split
    call s:create_split(a:config.window.position, a:config, v:null)

    " Determine if we should use the git root directory
    let l:cmd = 'terminal ' . a:config.command
    if a:config.git.use_git_root
      let l:git_root = claude_code#git#get_git_root()
      if l:git_root != v:null
        " Use cd to change directory with explicit path restoration
        let l:separator = a:config.shell.separator
        let l:cmd = 'terminal cd ' . shellescape(l:git_root) . ' ' . l:separator . ' ' . a:config.command
      endif
    endif

    execute l:cmd
    setlocal bufhidden=hide

    " Create a unique buffer name (or a standard one in single instance mode)
    let l:buffer_name = ''
    if a:config.git.multi_instance
      let l:buffer_name = 'claude-code-' . substitute(l:instance_id, '[^[:alnum:]\-_]', '-', 'g')
    else
      let l:buffer_name = 'claude-code'
    endif
    execute 'file ' . l:buffer_name

    if a:config.window.hide_numbers
      setlocal nonumber norelativenumber
    endif

    if a:config.window.hide_signcolumn
      setlocal signcolumn=no
    endif

    " Store buffer number for this instance
    let a:claude_code.claude_code.instances[l:instance_id] = bufnr('%')

    " Automatically enter insert mode in terminal unless configured to start in normal mode
    if a:config.window.enter_insert && !a:config.window.start_in_normal_mode
      startinsert
    endif
  endif
endfunction