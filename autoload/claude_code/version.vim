" Version information for claude-code.vim
" This module provides version information for claude-code.vim.

" Individual version components
let s:major = 0
let s:minor = 4
let s:patch = 2

" Combined semantic version
let s:version = s:major . '.' . s:minor . '.' . s:patch

" Returns the formatted version string (for backward compatibility)
" @return string Version string in format "major.minor.patch"
function! claude_code#version#string() abort
  return s:version
endfunction

" Prints the current version of the plugin
function! claude_code#version#print_version() abort
  echo 'Claude Code version: ' . claude_code#version#string()
endfunction

" Get individual version components (for compatibility)
function! claude_code#version#major() abort
  return s:major
endfunction

function! claude_code#version#minor() abort
  return s:minor
endfunction

function! claude_code#version#patch() abort
  return s:patch
endfunction

" Get version as dictionary (for compatibility with Lua module)
function! claude_code#version#get() abort
  return {
    \ 'major': s:major,
    \ 'minor': s:minor,
    \ 'patch': s:patch,
    \ 'version': s:version
    \ }
endfunction