-- Red PROD / blue STAGING / green LOCAL badge for dadbod windows (see dadbod.lua).
local function db_env()
	local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
	return _G.db_env_for_win and _G.db_env_for_win(win)
end

local db_env_badge = {
	function()
		local env = db_env()
		return env and ("\239\129\177 " .. env.label) or "" -- U+F071 nf-fa-warning
	end,
	cond = function()
		return db_env() ~= nil
	end,
	color = function()
		local env = db_env()
		return env and { fg = "#1e2127", bg = env.badge, gui = "bold" } or nil
	end,
}

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { "⏽", "⏽" },
		section_separators = { "", "" },
		disabled_filetypes = {},
	},
	sections = {
		lualine_a = { db_env_badge, "mode" },
		lualine_b = { {
			"branch",
			separator = "",
		}, "diff" },
		lualine_c = { "filename" },
		lualine_x = {
			{
				"diagnostics",
				sources = { "nvim_lsp" },
				separator = "",
				symbols = {
					error = "",
					warn = "",
					info = "",
					hint = "",
				},
			},
			{ "filetype" },
			"filesize",
			"fileformat",
			"encoding",
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { db_env_badge, "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = { "nvim-tree" },
})
