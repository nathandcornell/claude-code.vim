" Command registration for claude-code.vim
" This module provides command registration and handling for claude-code.vim.
" It defines user commands and command handlers.

" Register commands for the claude-code plugin
" @param claude_code dict The main plugin module functions
function! claude_code#commands#register_commands(claude_code) abort
  " Create the user command for toggling Claude Code
  command! ClaudeCode call claude_code#toggle()

  " Create commands for each command variant
  for l:variant_name in keys(a:claude_code.config.command_variants)
    let l:variant_args = a:claude_code.config.command_variants[l:variant_name]
    if l:variant_args != v:false
      " Convert variant name to PascalCase for command name (e.g., "continue" -> "Continue")
      let l:capitalized_name = toupper(l:variant_name[0]) . l:variant_name[1:]
      let l:cmd_name = 'ClaudeCode' . l:capitalized_name

      " Create the command dynamically
      execute 'command! ' . l:cmd_name . ' call claude_code#toggle_with_variant("' . l:variant_name . '")'
    endif
  endfor

  " Add version command
  command! ClaudeCodeVersion echo 'Claude Code version: ' . claude_code#version#string()
endfunction