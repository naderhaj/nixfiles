local paths = require("nix-paths")

-- Telescope runs fd/rg with --no-ignore so untracked and hidden files show up,
-- but that also turns off .gitignore handling entirely. Anything we still never
-- want in results has to be listed here. Single source of truth for the
-- find_files, live_grep and live_multigrep pickers below.
local junk = {
  ".git",
  ".DS_Store",
  ".direnv",
  ".cache",
  "result",          -- nix build symlink
  "node_modules",
  ".next",
  "dist",
  "build",
  "target",          -- rust / scala
  ".bloop",          -- scala / metals
  ".metals",
  ".gradle",
  "__pycache__",
  ".venv",
  ".mypy_cache",
  ".pytest_cache",
  ".ruff_cache",
  ".terraform",
  "vendor",
}

-- fd spells exclusions `--exclude <pat>`, ripgrep spells them `--glob !<pat>`.
-- Both use gitignore matching, so a bare name matches at any depth and takes
-- the directory's contents with it.
local function fd_excludes()
  local out = {}
  for _, pattern in ipairs(junk) do
    table.insert(out, "--exclude")
    table.insert(out, pattern)
  end
  return out
end

local function rg_excludes()
  local out = {}
  for _, pattern in ipairs(junk) do
    table.insert(out, "--glob")
    table.insert(out, "!" .. pattern)
  end
  return out
end

vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd> Telescope find_files<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<C-p>', "<cmd> Telescope find_files<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd> Telescope live_grep<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd> Telescope buffers<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd> Telescope help_tags<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>ft', "<cmd> Telescope<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fvcw', "<cmd> Telescope git_commits<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fvcb', "<cmd> Telescope git_bcommits<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fvb', "<cmd> Telescope git_branches<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fvs', "<cmd> Telescope git_status<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fvx', "<cmd> Telescope git_stash<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd> Telescope treesitter<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>flsb', "<cmd> Telescope lsp_document_symbols<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>flsw', "<cmd> Telescope lsp_workspace_symbols<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>flr', "<cmd> Telescope lsp_references<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>fli', "<cmd> Telescope lsp_implementations<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>flD', "<cmd> Telescope lsp_definitions<CR>", {
    noremap = true,
    silent = true
});

vim.api.nvim_set_keymap('n', '<leader>flt', "<cmd> Telescope lsp_type_definitions<CR>", {
    noremap = true,
    silent = true
});
vim.api.nvim_set_keymap('n', '<leader>fld', "<cmd> Telescope diagnostics<CR>", {
    noremap = true,
    silent = true
});
require("telescope").setup {
    defaults = {
      -- --hidden/--no-ignore match the find_files picker below, so grep sees
      -- the same set of files the file picker shows.
      vimgrep_arguments = vim.list_extend({
        paths.ripgrep,
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--fixed-strings",
        "--hidden",
        "--no-ignore",
      }, rg_excludes()),
    },
    pickers = {
      find_files = {
        -- fd skips dotfiles and anything matched by .gitignore by default,
        -- which hid every dotfile. Show those, minus the junk list at the top.
        find_command = vim.list_extend({
          paths.fd,
          "--type", "f",
          "--hidden",
          "--no-ignore",
        }, fd_excludes()),
      },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- even more opts
        }

        -- pseudo code / specification for writing custom displays, like the one
        -- for "codeactions"
        -- specific_opts = {
        --   [kind] = {
        --     make_indexed = function(items) -> indexed_items, width,
        --     make_displayer = function(widths) -> displayer
        --     make_display = function(displayer) -> function(e)
        --     make_ordinal = function(e) -> string
        --   },
        --   -- for example to disable the custom builtin "codeactions" display
        --      do the following
        --   codeactions = false,
        -- }
      }
    }
  }

-- Custom live_multigrep function for Telescope
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { paths.ripgrep }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      return vim
        .iter({
          args,
          {
            "--color=never", "--no-heading", "--with-filename", "--line-number", "--column",
            "--smart-case", "--hidden", "--no-ignore",
          },
          rg_excludes(),
        })
        :flatten()
        :totable()
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "Multi Grep",
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end

vim.keymap.set("n", "<leader>fm", live_multigrep, { desc = "Multi Grep (rg with pattern)" })

-- Tab picker (no builtin exists): one entry per tab page listing its files.
-- <CR> jumps to the tab, <C-d> closes it.
local function tab_entries()
  local results = {}
  for nr, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local names = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      -- skip floats (notifications, telescope itself)
      if vim.api.nvim_win_get_config(win).relative == "" then
        local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        -- fugitive:///repo/.git//<sha>/path -> path @ <short sha>
        local sha, path = name:match("^fugitive://.-//(%x+)/(.*)$")
        name = sha and (path .. " @" .. sha:sub(1, 7)) or vim.fn.fnamemodify(name, ":~:.")
        table.insert(names, name ~= "" and name or "[No Name]")
      end
    end
    local current = tab == vim.api.nvim_get_current_tabpage() and "%" or " "
    table.insert(results, { nr = nr, tab = tab, text = ("%s %d: %s"):format(current, nr, table.concat(names, "  |  ")) })
  end
  return results
end

local function tabs_picker(opts)
  opts = opts or {}
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local new_finder = function()
    return finders.new_table({
      results = tab_entries(),
      entry_maker = function(e)
        return { value = e, display = e.text, ordinal = e.text }
      end,
    })
  end

  pickers
    .new(opts, {
      prompt_title = "Tabs",
      finder = new_finder(),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and vim.api.nvim_tabpage_is_valid(entry.value.tab) then
            vim.api.nvim_set_current_tabpage(entry.value.tab)
          end
        end)
        local close_tab = function()
          local entry = action_state.get_selected_entry()
          if not entry or #vim.api.nvim_list_tabpages() == 1 then
            return
          end
          local nr = vim.api.nvim_tabpage_get_number(entry.value.tab)
          if entry.value.tab == vim.api.nvim_get_current_tabpage() then
            -- the picker's own windows live in this tab; close it first
            actions.close(prompt_bufnr)
            vim.cmd.tabclose(nr)
            return
          end
          vim.cmd.tabclose(nr)
          action_state.get_current_picker(prompt_bufnr):refresh(new_finder(), { reset_prompt = false })
        end
        map({ "i", "n" }, "<C-d>", close_tab)
        return true
      end,
    })
    :find()
end

vim.keymap.set("n", "<leader>fT", tabs_picker, { desc = "Tabs" })

-- fzf-native sorter for every picker: 'exact  ^prefix  suffix$  !negate  a | b
-- pcall so this file can be :luafile'd before the plugin is installed.
pcall(require("telescope").load_extension, "fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })

-- Grep the word under the cursor, or the selection in any visual mode.
-- builtin.grep_string alone only reads charwise `v` selections, and it
-- regex-escapes the text (`.` -> `\.`), which then matches nothing because
-- vimgrep_arguments above uses --fixed-strings. use_regex = true skips the
-- escaping; --fixed-strings still makes the search literal.
local function grep_word_or_selection()
  local text
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    lines = vim.tbl_filter(function(l)
      return vim.trim(l) ~= ""
    end, lines)
    -- rg matches one line at a time, so a multi-line selection uses its first line
    if #lines > 1 then
      vim.notify("Grep: multi-line selection, searching its first line", vim.log.levels.INFO)
    end
    text = vim.trim(lines[1] or "")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  else
    text = vim.fn.expand("<cword>")
  end
  if text == "" then
    return
  end
  builtin.grep_string({ search = text, use_regex = true })
end
vim.keymap.set({ "n", "x" }, "<leader>fw", grep_word_or_selection, { desc = "Grep word / selection" })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
-- Visual: commits touching the selected lines. Normal: commits touching the current line.
vim.keymap.set({ "n", "x" }, "<leader>gL", builtin.git_bcommits_range, { desc = "Commits touching line / selection" })
