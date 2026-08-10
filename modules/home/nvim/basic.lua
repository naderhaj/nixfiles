local g = vim.g
local o = vim.o

-- disable netrw at the very start of your init.lua (strongly advised)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- leader
g.mapleader = " "
g.localmapleader = " "

o.number = true
o.relativenumber = true
o.updatetime = 300
o.mouse = "v"
o.swapfile = false
o.scrollback = 100000
o.termguicolors = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.cmdheight = 2
o.clipboard = "unnamedplus"
o.smartindent = true
o.hidden = true
o.autoindent = true
o.expandtab = true
o.syntax = "on"
o.spelllang = "en_us"
o.spell = false
o.ignorecase = true
o.smartcase = true
o.confirm = true
o.signcolumn = "yes"

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.md",
	command = "setlocal spell",
})

vim.api.nvim_set_keymap("n", "<space>", "<nop>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<C-z>", ":nohlsearch<CR>", {
	noremap = true,
	silent = true,
})

-- window actions with Meta instead of <C-w>
-- switching
vim.api.nvim_set_keymap("n", "<M-h>", "<C-w>h", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-j>", "<C-w>j", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-k>", "<C-w>k", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-l>", "<C-w>l", {
	noremap = true,
	silent = true,
})

-- moving
vim.api.nvim_set_keymap("n", "<M-H>", "<C-w>H", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-J>", "<C-w>J", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-K>", "<C-w>K", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-L>", "<C-w>L", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-x>", "<C-w>x", {
	noremap = true,
	silent = true,
})
-- resizing
vim.api.nvim_set_keymap("n", "<M-<>", "<C-w><", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M->>", "<C-w>>", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-+>", "<C-w>+", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-->", "<C-w>-", {
	noremap = true,
	silent = true,
})

vim.api.nvim_set_keymap("n", "<M-=>", "<C-w>=", {
	noremap = true,
	silent = true,
})

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep search results centered
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- replace
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- tab in visual mode
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- tab in normal mode
--vim.api.nvim_set_keymap('n', '<Tab>', '>>_', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<S-Tab>', '<<_', {noremap = true, silent = true})

-- maximize tab
function _G.toggle_maximize_split()
	if vim.g.is_maximized == nil or vim.g.is_maximized == false then
		-- Save original window sizes
		vim.g.original_win_height = vim.api.nvim_win_get_height(0)
		vim.g.original_win_width = vim.api.nvim_win_get_width(0)

		-- Maximize current window
		vim.api.nvim_command("resize | resize")
		vim.api.nvim_command("vertical resize | vertical resize")

		vim.g.is_maximized = true
	else
		-- Restore the window to its original size
		vim.api.nvim_win_set_height(0, vim.g.original_win_height)
		vim.api.nvim_win_set_width(0, vim.g.original_win_width)

		vim.g.is_maximized = false
	end
end

vim.api.nvim_set_keymap("n", "<F10>", ":lua toggle_maximize_split()<CR>", { noremap = true, silent = true })
-- highlight yank
vim.cmd([[
  augroup highlight_yank
      autocmd!
      au TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=200 }
  augroup END
]])

vim.api.nvim_set_keymap("x", "<leader>p", '"_dP', { noremap = true, silent = true })

-- close buffer
vim.api.nvim_set_keymap("n", "<leader>bx", ":bd<CR>", {
	noremap = true,
	silent = true,
})

-- close all buffers
vim.api.nvim_set_keymap("n", "<leader>ba", ":bufdo bd<CR>", {
	noremap = true,
	silent = true,
})

local function close_all_buffers_except_current()
	local current = vim.api.nvim_get_current_buf()
	local buffers = vim.api.nvim_list_bufs()

	for _, buf in ipairs(buffers) do
		if buf ~= current and vim.api.nvim_buf_is_valid(buf) then
			local modified = vim.api.nvim_buf_get_option(buf, "modified")
			if not modified then
				pcall(vim.api.nvim_buf_delete, buf, {})
			end
		end
	end
end

vim.keymap.set("n", "<leader>bo", close_all_buffers_except_current, {
	noremap = true,
	silent = true,
})
