-- nvim-treesitter's `main` branch no longer takes highlight/indent options in
-- setup(); highlighting has to be started per buffer. Parsers come from Nix
-- (nvim-treesitter.withPlugins), so pcall skips filetypes without one.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

require("nvim-ts-autotag").setup()

require("treesitter-context").setup({
	enable = false,
	max_lines = 0,
})
