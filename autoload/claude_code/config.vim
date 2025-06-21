" Configuration management for claude-code.vim
" This module handles configuration management and validation for claude-code.vim.
" It provides the default configuration, validation, and merging of user config.

" Default configuration options
function! s:get_default_config() abort
  return {
    \ 'window': {
    \   'split_ratio': 0.3,
    \   'height_ratio': 0.3,
    \   'position': 'botright',
    \   'enter_insert': v:true,
    \   'start_in_normal_mode': v:false,
    \   'hide_numbers': v:true,
    \   'hide_signcolumn': v:true,
    \ },
    \ 'refresh': {
    \   'enable': v:true,
    \   'updatetime': 100,
    \   'timer_interval': 1000,
    \   'show_notifications': v:true,
    \ },
    \ 'git': {
    \   'use_git_root': v:true,
    \   'multi_instance': v:true,
    \ },
    \ 'shell': {
    \   'separator': '&&',
    \   'pushd_cmd': 'pushd',
    \   'popd_cmd': 'popd',
    \ },
    \ 'command': 'claude',
    \ 'command_variants': {
    \   'continue': '--continue',
    \   'resume': '--resume',
    \   'verbose': '--verbose',
    \ },
    \ 'keymaps': {
    \   'toggle': {
    \     'normal': '<C-,>',
    \     'terminal': '<C-,>',
    \     'variants': {
    \       'continue': '<leader>cC',
    \       'verbose': '<leader>cV',
    \     },
    \   },
    \   'window_navigation': v:true,
    \   'scrolling': v:true,
    \ },
    \ }
endfunction

" Validate the configuration
" @param config dict Configuration dictionary
" @return [boolean, string] [valid, error_message]
function! s:validate_config(config) abort
  " Validate window settings
  if type(a:config.window) != v:t_dict
    return [v:false, 'window config must be a dictionary']
  endif

  if type(a:config.window.split_ratio) != v:t_float && type(a:config.window.split_ratio) != v:t_number
    return [v:false, 'window.split_ratio must be a number']
  endif

  if a:config.window.split_ratio <= 0 || a:config.window.split_ratio > 1
    return [v:false, 'window.split_ratio must be a number between 0 and 1']
  endif

  if type(a:config.window.position) != v:t_string
    return [v:false, 'window.position must be a string']
  endif

  if type(a:config.window.enter_insert) != v:t_bool
    return [v:false, 'window.enter_insert must be a boolean']
  endif

  if type(a:config.window.start_in_normal_mode) != v:t_bool
    return [v:false, 'window.start_in_normal_mode must be a boolean']
  endif

  if type(a:config.window.hide_numbers) != v:t_bool
    return [v:false, 'window.hide_numbers must be a boolean']
  endif

  if type(a:config.window.hide_signcolumn) != v:t_bool
    return [v:false, 'window.hide_signcolumn must be a boolean']
  endif

  " Validate refresh settings
  if type(a:config.refresh) != v:t_dict
    return [v:false, 'refresh config must be a dictionary']
  endif

  if type(a:config.refresh.enable) != v:t_bool
    return [v:false, 'refresh.enable must be a boolean']
  endif

  if type(a:config.refresh.updatetime) != v:t_number || a:config.refresh.updatetime <= 0
    return [v:false, 'refresh.updatetime must be a positive number']
  endif

  if type(a:config.refresh.timer_interval) != v:t_number || a:config.refresh.timer_interval <= 0
    return [v:false, 'refresh.timer_interval must be a positive number']
  endif

  if type(a:config.refresh.show_notifications) != v:t_bool
    return [v:false, 'refresh.show_notifications must be a boolean']
  endif

  " Validate git settings
  if type(a:config.git) != v:t_dict
    return [v:false, 'git config must be a dictionary']
  endif

  if type(a:config.git.use_git_root) != v:t_bool
    return [v:false, 'git.use_git_root must be a boolean']
  endif

  if type(a:config.git.multi_instance) != v:t_bool
    return [v:false, 'git.multi_instance must be a boolean']
  endif

  " Validate shell settings
  if type(a:config.shell) != v:t_dict
    return [v:false, 'shell config must be a dictionary']
  endif

  if type(a:config.shell.separator) != v:t_string
    return [v:false, 'shell.separator must be a string']
  endif

  if type(a:config.shell.pushd_cmd) != v:t_string
    return [v:false, 'shell.pushd_cmd must be a string']
  endif

  if type(a:config.shell.popd_cmd) != v:t_string
    return [v:false, 'shell.popd_cmd must be a string']
  endif

  " Validate command settings
  if type(a:config.command) != v:t_string
    return [v:false, 'command must be a string']
  endif

  " Validate command variants settings
  if type(a:config.command_variants) != v:t_dict
    return [v:false, 'command_variants config must be a dictionary']
  endif

  " Check each command variant
  for l:variant_name in keys(a:config.command_variants)
    let l:variant_args = a:config.command_variants[l:variant_name]
    if !(l:variant_args == v:false || type(l:variant_args) == v:t_string)
      return [v:false, 'command_variants.' . l:variant_name . ' must be a string or false']
    endif
  endfor

  " Validate keymaps settings
  if type(a:config.keymaps) != v:t_dict
    return [v:false, 'keymaps config must be a dictionary']
  endif

  if type(a:config.keymaps.toggle) != v:t_dict
    return [v:false, 'keymaps.toggle must be a dictionary']
  endif

  if !(a:config.keymaps.toggle.normal == v:false || type(a:config.keymaps.toggle.normal) == v:t_string)
    return [v:false, 'keymaps.toggle.normal must be a string or false']
  endif

  if !(a:config.keymaps.toggle.terminal == v:false || type(a:config.keymaps.toggle.terminal) == v:t_string)
    return [v:false, 'keymaps.toggle.terminal must be a string or false']
  endif

  " Validate variant keymaps if they exist
  if has_key(a:config.keymaps.toggle, 'variants')
    if type(a:config.keymaps.toggle.variants) != v:t_dict
      return [v:false, 'keymaps.toggle.variants must be a dictionary']
    endif

    " Check each variant keymap
    for l:variant_name in keys(a:config.keymaps.toggle.variants)
      let l:keymap = a:config.keymaps.toggle.variants[l:variant_name]
      if !(l:keymap == v:false || type(l:keymap) == v:t_string)
        return [v:false, 'keymaps.toggle.variants.' . l:variant_name . ' must be a string or false']
      endif
      " Ensure variant exists in command_variants
      if l:keymap != v:false && !has_key(a:config.command_variants, l:variant_name)
        return [v:false, 'keymaps.toggle.variants.' . l:variant_name . ' has no corresponding command variant']
      endif
    endfor
  endif

  if type(a:config.keymaps.window_navigation) != v:t_bool
    return [v:false, 'keymaps.window_navigation must be a boolean']
  endif

  if type(a:config.keymaps.scrolling) != v:t_bool
    return [v:false, 'keymaps.scrolling must be a boolean']
  endif

  return [v:true, '']
endfunction

" Deep merge two dictionaries (similar to vim.tbl_deep_extend)
function! s:deep_extend(dst, src) abort
  let l:result = deepcopy(a:dst)
  
  for l:key in keys(a:src)
    if type(a:src[l:key]) == v:t_dict && has_key(l:result, l:key) && type(l:result[l:key]) == v:t_dict
      let l:result[l:key] = s:deep_extend(l:result[l:key], a:src[l:key])
    else
      let l:result[l:key] = deepcopy(a:src[l:key])
    endif
  endfor
  
  return l:result
endfunction

" Parse user configuration and merge with defaults
" @param user_config dict|v:null User configuration dictionary (optional)
" @param silent boolean Set to true to suppress error notifications (for tests)
" @return dict Merged configuration
function! claude_code#config#parse_config(...) abort
  let l:user_config = get(a:, 1, {})
  let l:silent = get(a:, 2, v:false)
  
  " Handle backward compatibility first
  if type(l:user_config) == v:t_dict && has_key(l:user_config, 'window')
    if has_key(l:user_config.window, 'height_ratio') && !has_key(l:user_config.window, 'split_ratio')
      " Copy height_ratio to split_ratio for backward compatibility
      let l:user_config.window.split_ratio = l:user_config.window.height_ratio
    endif
  endif

  let l:default_config = s:get_default_config()
  let l:config = s:deep_extend(l:default_config, l:user_config)

  let [l:valid, l:err] = s:validate_config(l:config)
  if !l:valid
    " Only notify if not in silent mode
    if !l:silent
      echohl ErrorMsg
      echomsg 'Claude Code: ' . l:err
      echohl None
    endif
    " Fall back to default config in case of error
    return deepcopy(l:default_config)
  endif

  return l:config
endfunction

" Get the default configuration (for testing/reference)
function! claude_code#config#get_default() abort
  return s:get_default_config()
endfunction