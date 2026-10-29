vim.wo.colorcolumn = "99999"
vim.opt.list = true

require("ibl").setup {
  scope = {
    enabled = true,
    char = "│",
    injected_languages = true,
    show_end = true,
  }
}

vim.g.cursorline_timeout = 0
