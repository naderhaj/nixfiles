require("trouble").setup({})

vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", {
	noremap = true,
	silent = true,
	desc = "Trouble: Toggle",
})

vim.api.nvim_set_keymap("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", {
	noremap = true,
	silent = true,
	desc = "Buffer Diagnostics",
})

vim.api.nvim_set_keymap("n", "<leader>ll", "<cmd>Trouble lsp toggle focus=true<cr>", {
	noremap = true,
	silent = true,
	desc = "Trouble: LSP Definitions / references",
})

vim.api.nvim_set_keymap("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", {
	noremap = true,
	silent = true,
	desc = "Location List (Trouble)",
})

vim.api.nvim_set_keymap("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", {
	noremap = true,
	silent = true,
	desc = "Quickfix List (Trouble)",
})

vim.api.nvim_set_keymap("n", "<leader>ltd", "<cmd>Trouble diagnostics toggle focus=true filter.buf=0 win.type=split win.position=bottom<CR>", {
	noremap = true,
	silent = true,
	desc = "Trouble: Buffer Diagnostics",
})

vim.api.nvim_set_keymap("n", "<leader>lts", "<cmd>Trouble symbols toggle focus=true filter.buf=0 win.type=split win.position=bottom<CR>", {
	noremap = true,
	silent = true,
	desc = "Trouble: Document Symbols",
})
