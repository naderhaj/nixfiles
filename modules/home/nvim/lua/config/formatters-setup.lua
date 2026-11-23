local util = require("conform.util")

-- set formatting shortcut if lsp is not attached
vim.api.nvim_set_keymap("n", "<leader>lf", '<cmd>lua require("conform").format({lsp_format = "fallback" })<CR>', {
    noremap = true,
    silent = true,
})

-- Project-config markers used to pick the right formatter per repo.
local OXC = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }
local RUFF = { "ruff.toml", ".ruff.toml", "pyproject.toml" }

---Nearest config file walking up from the buffer's directory, or nil.
---@param bufnr integer
---@param names string[]
---@return string|nil
local function upward(bufnr, names)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return vim.fs.find(names, { upward = true, path = vim.fs.dirname(name) })[1]
end

-- Oxc repos are formatted with oxfmt; everything else keeps prettier.
local function js_fmt(bufnr)
  return upward(bufnr, OXC) and { "oxfmt" } or { "prettier" }
end

-- An Oxc repo's .oxfmtrc.json ignores *.md/*.yml/*.yaml/*.html, and oxfmt has no
-- CSS support, so those files have no team standard there. Returning {} leaves
-- them untouched instead of imposing prettier's defaults on them.
local function prettier_unless_oxc(bufnr)
  return upward(bufnr, OXC) and {} or { "prettier" }
end

-- Sort imports before formatting when the project has a ruff config, matching
-- what `ruff check --fix` does in pre-commit (e.g. isort force-single-line).
local function py_fmt(bufnr)
  if upward(bufnr, RUFF) then
    return { "ruff_organize_imports", "ruff_format" }
  end
  return { "ruff_format" }
end

require("conform").setup({

  format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,

  formatters_by_ft = {
    python = py_fmt,
    lua = { "stylua" },
    nix = { "nixfmt" },
    html = prettier_unless_oxc,
    css = prettier_unless_oxc,
    markdown = prettier_unless_oxc,
    typescript = js_fmt,
    javascript = js_fmt,
    typescriptreact = js_fmt,
    javascriptreact = js_fmt,
    -- For filetypes without an explicit formatter, fall back to LSP
    go = { lsp_format = "prefer" },
  },

  notify_on_error = true,

  formatters = {
    -- Builtin ruff formatters. They inherit --force-exclude (honours
    -- extend-exclude), range_args, and cwd = root of pyproject.toml/ruff.toml.
    ruff_format = {
      command = "ruff",
    },
    ruff_organize_imports = {
      command = "ruff",
    },
    stylua = {
      command = "stylua",
    },
    -- Prefer the project's pinned prettier, fall back to the one on PATH.
    prettier = {
      command = util.find_executable({ "node_modules/.bin/prettier" }, "prettier"),
    },
    nixfmt = {
      command = "nixfmt",
    },
    -- oxfmt: builtin used as-is. Its command is util.from_node_modules("oxfmt"),
    -- so the version always matches what the repo's CI and pre-commit run.
  },
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
