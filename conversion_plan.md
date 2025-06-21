# Strangler Fig Pattern Development Plan

## Overview
Convert the claude-code.vim plugin from Lua to Vimscript using the strangler fig pattern for iterative, low-risk migration.

## Architecture Advantages
- **Clean dependency hierarchy**: `init.lua` → all other modules (no circular dependencies)
- **Parameter injection pattern**: Modules receive dependencies as parameters, not imports
- **Leaf node majority**: 7 of 8 modules are independent leaf nodes
- **Modular design**: Each module has single responsibility

## Conversion Phases

### Phase 1: Foundation Modules (Weeks 1-2)
**Target**: Independent utility modules with no dependencies

1. **version.lua** → `autoload/claude_code/version.vim`
   - **Complexity**: Low (48 lines, metadata only)
   - **Functions**: `string()`, `print_version()`
   - **Risk**: Minimal

2. **git.lua** → `autoload/claude_code/git.vim`
   - **Complexity**: Low (49 lines, single function)
   - **Functions**: `get_git_root()`
   - **Risk**: Low

3. **config.lua** → `autoload/claude_code/config.vim`
   - **Complexity**: High (311 lines, validation logic)
   - **Functions**: `parse_config()`, `validate_config()`
   - **Risk**: Medium (complex validation logic)

### Phase 2: Feature Modules (Weeks 3-4)
**Target**: User-facing features that build on foundation

4. **commands.lua** → `autoload/claude_code/commands.vim`
   - **Complexity**: Low (40 lines, command registration)
   - **Dependencies**: Uses converted config module
   - **Risk**: Low

5. **keymaps.lua** → `autoload/claude_code/keymaps.vim`
   - **Complexity**: Medium (195 lines, keymap management)
   - **Dependencies**: Uses converted config module
   - **Risk**: Medium

6. **file_refresh.lua** → `autoload/claude_code/file_refresh.vim`
   - **Complexity**: Medium (123 lines, timer management)
   - **Dependencies**: Uses converted config module
   - **Risk**: Medium

### Phase 3: Core Integration (Weeks 5-6)
**Target**: Central functionality and orchestration

7. **terminal.lua** → `autoload/claude_code/terminal.vim`
   - **Complexity**: High (190 lines, complex window management)
   - **Dependencies**: Uses converted git module
   - **Risk**: High (core functionality)

8. **init.lua** → `plugin/claude-code.vim`
   - **Complexity**: Medium (127 lines, orchestration)
   - **Dependencies**: All converted modules
   - **Risk**: High (plugin entry point)

## Conversion Strategy Per Module

### File Structure
```
autoload/
  claude_code/
    version.vim
    git.vim
    config.vim
    commands.vim
    keymaps.vim
    file_refresh.vim
    terminal.vim
plugin/
  claude-code.vim
```

### Migration Process Per Module

1. **Create Vimscript equivalent** maintaining same public API
2. **Update references** in consuming modules to use new location
3. **Add backward compatibility** (optional Lua fallback)
4. **Test functionality** with existing test suite
5. **Remove Lua version** once verified

### Testing Strategy

1. **Maintain existing tests**: Plenary tests continue to work
2. **Add Vimscript-specific tests**: New tests in `test/` directory
3. **Integration testing**: Verify mixed Lua/Vimscript operation
4. **Regression testing**: Ensure no functionality loss

### Rollback Strategy

Each phase can be rolled back independently:
- Keep original Lua files until phase completion
- Use feature flags to toggle between implementations
- Maintain git branches for each phase

## Key Conversion Considerations

### Lua → Vimscript Patterns
- **Tables** → Dictionaries (`{}` → `{}`)
- **Functions** → Functions (`function` → `function!`)
- **Modules** → Autoload files (`require()` → `claude_code#module#function()`)
- **vim.api calls** → Native Vim functions
- **Error handling** → try/catch blocks

### API Compatibility
Maintain identical public APIs so existing users aren't affected:
```vim
" Same function signatures
call claude_code#config#parse_config(config)
call claude_code#terminal#toggle()
```

## Benefits of This Approach

1. **Low risk**: Each module conversion is isolated
2. **Testable**: Each phase can be fully tested before proceeding
3. **Reversible**: Any phase can be rolled back
4. **Incremental**: Users benefit from improved Vim compatibility immediately
5. **Maintainable**: Clear module boundaries make maintenance easier

## Module Dependency Analysis

### Dependency Graph
```
init.lua (root)
├── config.lua (leaf)
├── commands.lua (leaf)
├── keymaps.lua (leaf)
├── file_refresh.lua (leaf)
├── terminal.lua (leaf)
├── git.lua (leaf)
└── version.lua (leaf)
```

### Conversion Order Rationale

**Phase 1** modules are safe to convert first because:
- They have no internal dependencies
- They provide foundational services other modules need
- Conversion failures have minimal impact on overall functionality

**Phase 2** modules build on the foundation:
- They depend on Phase 1 modules being available
- They provide user-facing features but aren't core to the plugin's operation
- Each can be converted independently within this phase

**Phase 3** modules are the integration layer:
- `terminal.lua` contains the most complex logic and is central to plugin operation
- `init.lua` ties everything together and should be converted last
- These modules have the highest impact if conversion fails

The clean architecture makes this plugin ideal for strangler fig conversion, with minimal risk and maximum control over the migration process.