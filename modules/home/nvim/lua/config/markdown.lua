require("render-markdown").setup({})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(args)
		require("which-key").add({ { "<leader>m", group = "markdown", buffer = args.buf } })
		vim.keymap.set(
			"n",
			"<leader>mt",
			"<cmd>RenderMarkdown toggle<CR>",
			{ buffer = args.buf, desc = "toggle rendering" }
		)
	end,
})
