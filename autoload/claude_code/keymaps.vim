" Keymap management for claude-code.vim
" This module provides keymap registration and handling for claude-code.vim.
" It handles normal mode, terminal mode, and window navigation keymaps.

" Register keymaps for claude-code.vim
" @param claude_code dict The main plugin module
" @param config dict The plugin configuration
function! claude_code#keymaps#register_keymaps(claude_code, config) abort
  " Normal mode toggle keymaps
  if a:config.keymaps.toggle.normal != v:false
    execute 'nnoremap <silent> ' . a:config.keymaps.toggle.normal . ' <cmd>ClaudeCode<CR>'
  endif

  if a:config.keymaps.toggle.terminal != v:false
    " Terminal mode toggle keymap
    " In terminal mode, special keys like Ctrl need different handling
    execute 'tnoremap <silent> ' . a:config.keymaps.toggle.terminal . ' <C-\><C-n>:ClaudeCode<CR>'
  endif

  " Register variant keymaps if configured
  if has_key(a:config.keymaps.toggle, 'variants')
    for l:variant_name in keys(a:config.keymaps.toggle.variants)
      let l:keymap = a:config.keymaps.toggle.variants[l:variant_name]
      if l:keymap != v:false
        " Convert variant name to PascalCase for command name (e.g., "continue" -> "Continue")
        let l:capitalized_name = toupper(l:variant_name[0]) . l:variant_name[1:]
        let l:cmd_name = 'ClaudeCode' . l:capitalized_name

        execute 'nnoremap <silent> ' . l:keymap . ' <cmd>' . l:cmd_name . '<CR>'
      endif
    endfor
  endif
endfunction

" Set up terminal-specific keymaps for window navigation
" @param claude_code dict The main plugin module
" @param config dict The plugin configuration
function! claude_code#keymaps#setup_terminal_navigation(claude_code, config) abort
  " Get current active Claude instance buffer
  let l:current_instance = a:claude_code.claude_code.current_instance
  let l:buf = l:current_instance != v:null && has_key(a:claude_code.claude_code.instances, l:current_instance) 
    \ ? a:claude_code.claude_code.instances[l:current_instance] : v:null
  
  if l:buf != v:null && bufexists(l:buf)
    " Create autocommand group for this buffer
    let l:augroup_name = 'ClaudeCodeTerminalFocus_' . l:buf
    execute 'augroup ' . l:augroup_name
    autocmd!
    
    " Set up multiple events for more reliable focus detection
    execute 'autocmd WinEnter,BufEnter,WinLeave,FocusGained,CmdLineLeave <buffer=' . l:buf . '> call s:schedule_force_insert_mode()'
    
    augroup END

    " Window navigation keymaps
    if a:config.keymaps.window_navigation
      " Terminal mode window navigation
      execute 'tnoremap <buffer> <silent> <C-h> <C-\><C-n><C-w>h:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
      execute 'tnoremap <buffer> <silent> <C-j> <C-\><C-n><C-w>j:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
      execute 'tnoremap <buffer> <silent> <C-k> <C-\><C-n><C-w>k:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
      execute 'tnoremap <buffer> <silent> <C-l> <C-\><C-n><C-w>l:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'

      " Normal mode window navigation (for when user is in normal mode in the terminal)
      execute 'nnoremap <buffer> <silent> <C-h> <C-w>h:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
      execute 'nnoremap <buffer> <silent> <C-j> <C-w>j:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
      execute 'nnoremap <buffer> <silent> <C-k> <C-w>k:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
      execute 'nnoremap <buffer> <silent> <C-l> <C-w>l:call claude_code#keymaps#force_insert_mode_wrapper()<CR>'
    endif

    " Add scrolling keymaps
    if a:config.keymaps.scrolling
      execute 'tnoremap <buffer> <silent> <C-f> <C-\><C-n><C-f>i'
      execute 'tnoremap <buffer> <silent> <C-b> <C-\><C-n><C-b>i'
    endif
  endif
endfunction

" Helper function to schedule force_insert_mode call
function! s:schedule_force_insert_mode() abort
  " Use timer to schedule the call (similar to vim.schedule)
  call timer_start(0, function('s:force_insert_mode_timer'))
endfunction

" Timer callback for force_insert_mode
function! s:force_insert_mode_timer(timer_id) abort
  " This will need to be connected to the main plugin's force_insert_mode function
  " For now, we'll create a wrapper that can be called from the main module
  if exists('g:ClaudeCodeForceInsertModeFunc')
    call g:ClaudeCodeForceInsertModeFunc()
  endif
endfunction

" Wrapper function that the main plugin can set up
function! claude_code#keymaps#force_insert_mode_wrapper() abort
  if exists('g:ClaudeCodeForceInsertModeFunc')
    call g:ClaudeCodeForceInsertModeFunc()
  endif
endfunction

" Set the force insert mode function reference
function! claude_code#keymaps#set_force_insert_mode_func(func_ref) abort
  let g:ClaudeCodeForceInsertModeFunc = a:func_ref
endfunction