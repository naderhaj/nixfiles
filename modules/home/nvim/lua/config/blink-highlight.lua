local ns_id = vim.api.nvim_create_namespace("blink_highlight")

-- Create a custom highlight group with a smooth orange color
vim.api.nvim_set_hl(0, "BlinkHighlight", { bg = "#ff9e64", fg = "#1a1b26", bold = true })

local function blink_range(bufnr, start_line, end_line, blinks)
	local count = 0
	local max_blinks = blinks * 2

	local function toggle()
		if count >= max_blinks then
			vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
			return
		end

		if count % 2 == 0 then
			for line = start_line, end_line do
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "BlinkHighlight", line, 0, -1)
			end
		else
			vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
		end

		count = count + 1
		vim.defer_fn(toggle, 200)
	end

	toggle()
end

local function blink_line()
	local bufnr = vim.api.nvim_get_current_buf()
	local mode = vim.api.nvim_get_mode().mode

	if mode == "v" or mode == "V" or mode == "\22" then
		local start_line = vim.fn.line("v") - 1
		local end_line = vim.fn.line(".") - 1

		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end

		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
		vim.schedule(function()
			blink_range(bufnr, start_line, end_line, 3)
		end)
	else
		local line = vim.fn.line(".") - 1
		blink_range(bufnr, line, line, 3)
	end
end

vim.keymap.set({ "n", "v" }, "<leader><leader>", blink_line, { desc = "Blink highlight line/selection" })
