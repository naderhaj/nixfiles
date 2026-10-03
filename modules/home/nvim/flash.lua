require("flash").setup()

-- gs: jump anywhere on screen (type 2 chars, then the label)
vim.keymap.set({ "n", "x", "o" }, "gs", function()
	require("flash").jump()
end, { desc = "flash jump" })

-- gS: select a treesitter node; not in visual mode, where gS is nvim-surround's
vim.keymap.set({ "n", "o" }, "gS", function()
	require("flash").treesitter()
end, { desc = "flash treesitter" })
