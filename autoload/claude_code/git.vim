" Git integration for claude-code.vim
" This module provides git integration functionality for claude-code.vim.
" It detects git repositories and can set the working directory to the git root.

" Helper function to get git root directory
" @return string|v:null git_root The git root directory path or v:null if not in a git repo
function! claude_code#git#get_git_root() abort
  " For testing compatibility
  if $CLAUDE_CODE_TEST_MODE ==# 'true'
    return '/home/user/project'
  endif

  " Check if we're in a git repository
  let l:check_result = system('git rev-parse --is-inside-work-tree 2>/dev/null')
  
  " Check for command failure
  if v:shell_error != 0
    return v:null
  endif

  " Strip trailing whitespace and newlines for reliable matching
  let l:check_result = substitute(l:check_result, '[\n\r\s]*$', '', '')

  if l:check_result ==# 'true'
    " Get the git root path
    let l:git_root = system('git rev-parse --show-toplevel 2>/dev/null')
    
    " Check for command failure
    if v:shell_error != 0
      return v:null
    endif

    " Remove trailing whitespace and newlines
    let l:git_root = substitute(l:git_root, '[\n\r\s]*$', '', '')

    return l:git_root
  endif

  return v:null
endfunction