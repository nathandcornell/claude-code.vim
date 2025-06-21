# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project: Claude Code Neovim Plugin

## Overview

Claude Code Plugin provides seamless integration between the Claude Code AI assistant and Neovim. It enables direct communication with the Claude Code CLI from within the editor, supporting multi-instance usage, context-aware interactions, and automatic file synchronization.

## Essential Commands

### Primary Development Commands
- `make test` - Run Plenary test suite (primary testing framework)
- `make test-debug` - Run tests with verbose output and debugging
- `make lint` - Run LuaCheck static analysis
- `make format` - Format code with StyLua
- `make all` - Run complete build pipeline (lint, format, test, docs)

### Individual Test Commands
- `make test-legacy` - Run VimL-based legacy tests
- `make test-basic` - Run basic functionality tests only
- `make test-config` - Run configuration validation tests only
- `./scripts/test.sh` - Direct test runner script

### Manual Commands
- `luacheck lua/` - Direct linting
- `stylua lua/` - Direct formatting
- `stylua lua/ -c` - Check formatting without changes

## Architecture Overview

### Core Module Structure
The plugin uses a clean modular architecture with distinct responsibilities:

- **`init.lua`**: Main entry point, public API, and module coordination
- **`terminal.lua`**: Terminal buffer/window management and multi-instance system
- **`config.lua`**: Configuration parsing, validation, and type checking
- **`git.lua`**: Git repository detection and directory context management
- **`file_refresh.lua`**: File change detection and automatic reload system
- **`commands.lua`**: User command registration and variant handling
- **`keymaps.lua`**: Keymap management and terminal navigation
- **`version.lua`**: Version information and plugin metadata

### Multi-Instance Architecture
The plugin supports multiple Claude Code instances running simultaneously:

```lua
-- Instance management structure
M.terminal = {
  instances = {},         -- Map of git root paths to buffer numbers
  current_instance = nil, -- Active instance identifier
  saved_updatetime = nil  -- Backup of original updatetime setting
}
```

Key behaviors:
- One instance per git repository root (configurable)
- Automatic context switching between projects
- Proper cleanup of invalid buffers
- Directory isolation with pushd/popd commands

### Configuration System
Comprehensive configuration with validation:
- Type checking and range validation for all options
- Backward compatibility handling (e.g., `height_ratio` → `split_ratio`)
- Command variants system for different Claude modes
- Shell-specific command configuration (bash/zsh/nushell support)

### File Refresh Mechanism
Proactive file synchronization:
- Timer-based polling with configurable intervals
- Multiple trigger events (CursorHold, FocusGained, etc.)
- Temporary `updatetime` adjustment when Claude is active
- Optional user notifications for file changes

## Testing Framework

### Test Structure
- **Primary**: Plenary.nvim-based tests in `/tests/spec/`
- **Legacy**: VimL-based tests in `/test/` for backward compatibility
- **Custom runner**: `/tests/run_tests.lua` with detailed reporting

### Test Coverage Areas
- Configuration parsing and validation
- Terminal management and multi-instance behavior
- Git integration and directory context switching
- Command registration and keymap setup
- File refresh and auto-reload functionality
- Core integration scenarios

### Testing Best Practices
- Use `config.parse_config(user_config, true)` for silent mode in tests
- Mock vim APIs for isolated unit testing
- Test multi-instance scenarios with different git roots
- Verify buffer cleanup and resource management

## Code Quality Standards

### LuaCheck Configuration
- Cyclomatic complexity limit: 20 (30 for config validation)
- No ignored warnings - all issues must be resolved
- Neovim-specific globals and testing framework support
- Max line length: 120 characters

### StyLua Formatting
- Column width: 100
- 2-space indentation
- Auto-prefer single quotes
- Unix line endings

## Development Workflow

### Before Making Changes
1. Run `make lint` to check code quality
2. Run `make test` to ensure all tests pass
3. Use `make format` to ensure consistent styling

### When Adding Features
- Add corresponding tests in `/tests/spec/`
- Update configuration validation if adding new options
- Consider multi-instance compatibility
- Test with both git and non-git projects

### When Modifying Configuration
- Update `config.lua` validation logic
- Add backward compatibility handling if needed
- Update tests in `config_validation_spec.lua`
- Document breaking changes

## Key Implementation Details

### Terminal Window Management
- Supports various split positions (botright, topleft, vertical)
- Configurable split ratios and window behavior
- Automatic insert mode handling
- Terminal-specific navigation keymaps

### Git Integration
- Uses `git rev-parse --show-toplevel` for root detection
- Handles non-git directories gracefully
- Shell-agnostic directory switching (pushd/popd)
- Respects user's current working directory preferences

### Command Variant System
- Dynamic command generation based on `command_variants` config
- Supports flags like `--continue`, `--resume`, `--verbose`
- Temporary command modification during execution
- Proper restoration of original command state

## Important Notes

### Multi-Instance Behavior
- Each git repository maintains its own Claude instance
- Instance switching preserves directory context
- Buffer names include git root path for identification
- Configurable via `git.multi_instance` option (defaults to `true`)

### File Refresh Considerations
- Polling interval affects performance vs. responsiveness
- `updatetime` is temporarily reduced when Claude is active
- File change notifications can be disabled for quiet operation
- Handles both internal and external file modifications

### Testing Considerations
- Use silent mode configuration for test environments
- Mock filesystem operations for reliable testing
- Test cleanup thoroughly to prevent resource leaks
- Consider timing-sensitive operations in file refresh tests

## Lua to Vimscript Conversion

### Active Development
This project is currently being converted from Lua to Vimscript for improved Vim compatibility using the strangler fig pattern. See `conversion_plan.md` for the complete migration strategy.

### Conversion Progress
Track progress by striking through completed items in `conversion_plan.md`:

**Phase 1: Foundation Modules**
- [x] ~~version.lua → autoload/claude_code/version.vim~~
- [x] ~~git.lua → autoload/claude_code/git.vim~~  
- [x] ~~config.lua → autoload/claude_code/config.vim~~

**Phase 2: Feature Modules**
- [x] ~~commands.lua → autoload/claude_code/commands.vim~~
- [x] ~~keymaps.lua → autoload/claude_code/keymaps.vim~~
- [x] ~~file_refresh.lua → autoload/claude_code/file_refresh.vim~~

**Phase 3: Core Integration**
- [ ] terminal.lua → autoload/claude_code/terminal.vim
- [ ] init.lua → plugin/claude-code.vim

### Conversion Guidelines
- Maintain identical public APIs for backward compatibility
- Test each phase thoroughly before proceeding
- Keep original Lua files until verification complete
- Use `make test` to ensure no regressions

## References
- [Vimscript Documentation](https://learnvim.irian.to/vimscript/vimscript_basic_data_types)
- [Lua Reference Manual](https://www.lua.org/manual/5.4/)
- [NeoVim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
