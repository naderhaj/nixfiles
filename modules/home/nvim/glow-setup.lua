local paths = require("nix-paths")

require('glow').setup({
  border = "shadow",
  glow_path = paths.glow,
  pager = false,
  width = 120,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>mp", "<cmd>Glow<CR>", { buffer = args.buf, desc = "preview (glow)" })
  end,
})
