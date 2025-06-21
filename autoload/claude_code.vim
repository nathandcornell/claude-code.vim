" Main Claude Code API functions
" This module provides the main public API for claude-code.vim

" Toggle the Claude Code terminal window
function! claude_code#toggle() abort
  if !exists('g:claude_code_loaded')
    echoerr 'Claude Code plugin not loaded'
    return
  endif
  call <SID>plugin_toggle()
endfunction

" Toggle the Claude Code terminal window with a specific command variant
function! claude_code#toggle_with_variant(variant_name) abort
  if !exists('g:claude_code_loaded')
    echoerr 'Claude Code plugin not loaded'
    return
  endif
  call <SID>plugin_toggle_with_variant(a:variant_name)
endfunction

" Get the current version of the plugin
function! claude_code#get_version() abort
  return claude_code#version#string()
endfunction

" Version information (for compatibility)
function! claude_code#version() abort
  return claude_code#version#string()
endfunction

" Setup function for the plugin
function! claude_code#setup(...) abort
  if !exists('g:claude_code_loaded')
    echoerr 'Claude Code plugin not loaded'
    return
  endif
  call call('<SID>plugin_setup', a:000)
endfunction

" Force insert mode when entering the Claude Code window
function! claude_code#force_insert_mode() abort
  if !exists('g:claude_code_loaded')
    return
  endif
  call <SID>plugin_force_insert_mode()
endfunction

" These functions are set by the plugin file when it loads
function! s:plugin_toggle() abort
  if exists('*g:ClaudeCodePluginToggle')
    call g:ClaudeCodePluginToggle()
  endif
endfunction

function! s:plugin_toggle_with_variant(variant_name) abort
  if exists('*g:ClaudeCodePluginToggleWithVariant')
    call g:ClaudeCodePluginToggleWithVariant(a:variant_name)
  endif
endfunction

function! s:plugin_setup(...) abort
  if exists('*g:ClaudeCodePluginSetup')
    call call('g:ClaudeCodePluginSetup', a:000)
  endif
endfunction

function! s:plugin_force_insert_mode() abort
  if exists('*g:ClaudeCodePluginForceInsertMode')
    call g:ClaudeCodePluginForceInsertMode()
  endif
endfunction