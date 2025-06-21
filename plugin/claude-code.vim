" Claude Code Vim Integration
" A plugin for seamless integration between Claude Code AI assistant and Vim.
" This plugin provides a terminal-based interface to Claude Code within Vim.
"
" Requirements:
" - Vim 8.0 or later with terminal support
" - Claude Code CLI tool installed and available in PATH
"
" Usage:
" call claude_code#setup({configuration_dict})

" Prevent loading if already loaded or if Vim doesn't support terminals
if exists('g:claude_code_loaded') || !has('terminal')
  finish
endif
let g:claude_code_loaded = 1

" Plugin state
let g:claude_code = {
  \ 'config': {},
  \ 'claude_code': {},
  \ 'commands': {},
  \ }

" Initialize the claude_code terminal structure
function! s:init_claude_code_terminal() abort
  let g:claude_code.claude_code = claude_code#terminal#get_terminal()
endfunction

" Get the current active buffer number
" @return number|v:null bufnr Current Claude instance buffer number or v:null
function! s:get_current_buffer_number() abort
  " Get current instance from the instances table
  let l:current_instance = g:claude_code.claude_code.current_instance
  if l:current_instance != v:null && has_key(g:claude_code.claude_code.instances, l:current_instance)
    return g:claude_code.claude_code.instances[l:current_instance]
  endif
  return v:null
endfunction

" Force insert mode when entering the Claude Code window
" This is a script-local function used in keymaps
function! s:force_insert_mode() abort
  call claude_code#terminal#force_insert_mode(g:claude_code, g:claude_code.config)
endfunction

" Toggle the Claude Code terminal window
" This is a script-local function used by commands
function! s:toggle() abort
  call claude_code#terminal#toggle(g:claude_code, g:claude_code.config, {})

  " Set up terminal navigation keymaps after toggling
  let l:bufnr = s:get_current_buffer_number()
  if l:bufnr != v:null && bufexists(l:bufnr)
    call claude_code#keymaps#setup_terminal_navigation(g:claude_code, g:claude_code.config)
  endif
endfunction

" Toggle the Claude Code terminal window with a specific command variant
" @param variant_name string The name of the command variant to use
function! s:toggle_with_variant(variant_name) abort
  if empty(a:variant_name) || !has_key(g:claude_code.config.command_variants, a:variant_name)
    " If variant doesn't exist, fall back to regular toggle
    call s:toggle()
    return
  endif

  " Store the original command
  let l:original_command = g:claude_code.config.command

  " Set the command with the variant args
  let g:claude_code.config.command = l:original_command . ' ' . g:claude_code.config.command_variants[a:variant_name]

  " Call the toggle function with the modified command
  call claude_code#terminal#toggle(g:claude_code, g:claude_code.config, {})

  " Set up terminal navigation keymaps after toggling
  let l:bufnr = s:get_current_buffer_number()
  if l:bufnr != v:null && bufexists(l:bufnr)
    call claude_code#keymaps#setup_terminal_navigation(g:claude_code, g:claude_code.config)
  endif

  " Restore the original command
  let g:claude_code.config.command = l:original_command
endfunction

" Get the current version of the plugin
" @return string version Current version string
function! s:get_version() abort
  return claude_code#version#string()
endfunction

" Version information (for compatibility)
function! s:version() abort
  return claude_code#version#string()
endfunction

" Setup function for the plugin
" @param user_config dict User configuration dictionary (optional)
function! s:setup(...) abort
  let l:user_config = get(a:, 1, {})
  
  " Initialize terminal structure
  call s:init_claude_code_terminal()
  
  " Parse and validate configuration
  " Don't use silent mode for regular usage - users should see config errors
  let g:claude_code.config = claude_code#config#parse_config(l:user_config, v:false)

  " Set up autoread option
  set autoread

  " Set up file refresh functionality
  call claude_code#file_refresh#setup(g:claude_code, g:claude_code.config)

  " Register commands
  call claude_code#commands#register_commands(g:claude_code)

  " Register keymaps
  call claude_code#keymaps#register_keymaps(g:claude_code, g:claude_code.config)
  
  " Set up the force insert mode function reference for keymaps
  call claude_code#keymaps#set_force_insert_mode_func(function('claude_code#force_insert_mode'))
endfunction

" Set up global function references for the autoload API
let g:ClaudeCodePluginToggle = function('s:toggle')
let g:ClaudeCodePluginToggleWithVariant = function('s:toggle_with_variant')
let g:ClaudeCodePluginSetup = function('s:setup')
let g:ClaudeCodePluginForceInsertMode = function('s:force_insert_mode')

" Auto-setup with default configuration if not manually configured
augroup ClaudeCodeAutoSetup
  autocmd!
  autocmd VimEnter * if !exists('g:claude_code_setup_done') | call s:setup() | let g:claude_code_setup_done = 1 | endif
augroup END