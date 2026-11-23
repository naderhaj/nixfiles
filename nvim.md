# Neovim keybinds

## Basics

- `<leader>s` — substitute
- `*` / `#` — select word, then `cgn` to change, `.` to repeat

## Telescope

| Key | Action |
|-----|--------|
| `<C-p>` / `<leader>ff` | Find files |
| `<leader>fg` | Live grep (send to quickfix: `<C-q>`) |
| `<leader>fm` | Multi grep (pattern + file filter separated by two spaces) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>ft` | Telescope picker |
| `<leader>fs` | Treesitter symbols |
| `<leader>fvcw` | Git commits |
| `<leader>fvcb` | Git buffer commits |
| `<leader>fvb` | Git branches |
| `<leader>fvs` | Git status |
| `<leader>fvx` | Git stash |
| `<leader>flsb` | LSP document symbols |
| `<leader>flsw` | LSP workspace symbols |
| `<leader>flr` | LSP references |
| `<leader>fli` | LSP implementations |
| `<leader>flD` | LSP definitions |
| `<leader>flt` | LSP type definitions |
| `<leader>fld` | LSP diagnostics |

## LSP

| Key | Action |
|-----|--------|
| `K` / `<leader>lh` | Hover |
| `<leader>lgd` | Go to definition |
| `<leader>lgD` | Go to declaration |
| `<leader>lgt` | Go to type definition |
| `<leader>lgn` | Next diagnostic |
| `<leader>lgp` | Prev diagnostic |
| `<leader>ln` | Rename |
| `<leader>lf` | Format |
| `<leader>lca` | Code actions (preview) |
| `<leader>lsh` | Signature help |
| `<leader>lwa` | Add workspace folder |
| `<leader>lwr` | Remove workspace folder |
| `<leader>lwl` | List workspace folders |

### Formatters

Auto-formats on save. The JS/TS formatter is chosen per project, so each repo
gets the formatter its own CI and pre-commit enforce:

| Language | Formatter |
|----------|-----------|
| Python | ruff (organize imports, then format) |
| Lua | stylua |
| Nix | nixpkgs-fmt |
| TS / TSX / JS / JSX | oxfmt in Oxc repos, otherwise prettier |
| HTML / CSS / Markdown | prettier, except in Oxc repos where they are left alone |

A repo counts as an Oxc repo when an `.oxfmtrc.json` (or `.oxfmtrc.jsonc` /
`oxfmt.config.ts`) is found walking up from the file. oxfmt is resolved from the project's own
`node_modules/.bin`, never from nix, so the version always matches the team's.
In those repos Markdown, YAML, HTML and CSS have no team standard (oxfmt's
`ignorePatterns` skips them and it has no CSS support), so nothing formats them.

Prettier also prefers a project-local `node_modules/.bin/prettier` when one
exists, falling back to the nix binary.

Python picks up the project's own ruff config (line length, isort style) via
`--stdin-filename`; imports are sorted first so pre-commit has nothing left to
rewrite.

Commands:
- `:FormatDisable` — disable autoformat globally
- `:FormatDisable!` — disable autoformat for current buffer only
- `:FormatEnable` — re-enable autoformat

### Folds (ufo)

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open folds except kinds |
| `zm` | Close folds with |

### Rust

| Key | Action |
|-----|--------|
| `<leader>rr` | Runnables |
| `<leader>re` | Expand macro |
| `<leader>rc` | Open Cargo.toml |
| `<leader>rd` | Debuggables |

### Metals (Scala)

| Key | Action |
|-----|--------|
| `<leader>lmc` | Metals commands |
| `<leader>lmi` | Toggle implicit arguments |
| `<leader>ws` | Worksheet hover |
| `<leader>ad` | Open all diagnostics |
| `<leader>ac` | Code action menu |

## File tree (nvim-tree)

| Key | Action |
|-----|--------|
| `<C-f>` | Toggle tree |
| `<C-s>` | Find current file in tree |
| `<leader>tr` | Refresh tree |

## Buffers (bufferline)

| Key | Action |
|-----|--------|
| `<leader>bn` | Next buffer |
| `<leader>bp` | Prev buffer |
| `<leader>bc` | Pick buffer |
| `<leader>b1`–`b9` | Go to buffer N |
| `<leader>bmn` | Move buffer next |
| `<leader>bmp` | Move buffer prev |
| `<leader>bse` | Sort by extension |
| `<leader>bsd` | Sort by directory |
| `<leader>bsi` | Sort by ID |

## Terminal (toggleterm)

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |
| `<C-\><C-n>` | Exit terminal mode (back to normal) |

## Copilot

| Key | Action |
|-----|--------|
| `<C-j>` | Accept suggestion |

## JSON

| Key | Action |
|-----|--------|
| `<leader>jf` | Format JSON (via `jq`) |

## Markdown

| Key | Action |
|-----|--------|
| `<leader>p` | Preview with Glow |

## Undotree

| Key | Action |
|-----|--------|
| `<leader><F5>` | Toggle undotree |

## Window splits

| Key | Action |
|-----|--------|
| `<C-w>s` | Split horizontal |
| `<C-w>v` | Split vertical |
| `<C-w>c` | Close split |
