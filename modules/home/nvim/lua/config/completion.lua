require("blink.cmp").setup({
	-- same keys as the previous nvim-cmp setup
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<C-d>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
	},
	completion = {
		list = { selection = { preselect = true, auto_insert = false } }, -- like completeopt=noinsert
		-- a bit larger than the defaults (10 items tall, 15 cols min width)
		menu = { max_height = 15, min_width = 30 },
		-- defaults: 80 cols wide, 20 lines tall
		documentation = { auto_show = true, window = { max_width = 100, max_height = 30 } },
	},
	-- default: 10 lines tall
	signature = { enabled = true, window = { max_height = 15 } }, -- parameter hints while typing inside (...)
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		per_filetype = { sql = { "dadbod", "buffer" } },
		providers = {
			dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
			-- snippets are read from ~/.config/nvim/snippets/<filetype>.json;
			-- global.json applies to every filetype
			snippets = { opts = { global_snippets = { "global" } } },
		},
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
})
