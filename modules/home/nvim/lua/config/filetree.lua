vim.cmd([[ set cursorline ]])

vim.api.nvim_set_keymap("n", "<C-F>", ":NvimTreeToggle<CR>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<C-s>", ":NvimTreeFindFile<CR>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<leader>tr", ":NvimTreeRefresh<CR>", {
	noremap = true,
	silent = true,
})

require("nvim-tree").setup({
	disable_netrw = false,
	hijack_netrw = true,
	open_on_tab = false,
	diagnostics = {
		enable = true,
	},
	view = {
		width = 25,
		side = "left",
		preserve_window_proportions = true,
	},
	renderer = {
		add_trailing = true,
		group_empty = true,
		highlight_git = false,
		indent_markers = {
			enable = true,
		},
	},
	actions = {
		open_file = {
			quit_on_open = false,
			resize_window = false,
		},
	},
	git = {
		enable = true,
		ignore = false,
	},
	filters = {
		dotfiles = false,
		custom = { "*.DS_Store", "*.git", "node_modules", ".cache" },
	},
})

local function open_nvim_tree()
	require("nvim-tree.api").tree.open()
end

-- open nvim-tree on start
-- vim.api.nvim_create_autocmd({"VimEnter"}, {
--     callback = open_nvim_tree
-- })
