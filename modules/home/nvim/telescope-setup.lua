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
