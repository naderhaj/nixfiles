local wk = require("which-key")
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		local function nextHunk()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end

		local function prevHunk()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end

		wk.add({
			mode = "n",
			{ "<leader>g", group = "gitsigns" },
			---- blame gb
			{ "<leader>gb", "<cmd>lua require'gitsigns'.blame_line{full=true}<cr>", desc = "blame (full)" },
			-- diff this
			{
				"<leader>gd",
				"<cmd>lua require'gitsigns'.diffthis(nil, {vertical=true})<cr>",
				desc = "diff current file",
			},
			-- diff this ~
			{ "<leader>gD", "<cmd>lua require'gitsigns'.diffthis('~')<cr>", desc = "diff file" },
			-- S
			{ "<leader>gs", "<cmd>lua require'gitsigns'.stage_buffer()<cr>", desc = "stage buffer" },
			-- R
			{ "<leader>gr", "<cmd>lua require'gitsigns'.reset_buffer_index()<cr>", desc = "reset buffer" },
		})

		-- toggle
		wk.add({
			mode = "n",
			{ "<leader>gt", group = "toggle" },
			-- toggle current line blame
			{
				"<leader>gtb",
				"<cmd>Gitsigns toggle_current_line_blame<cr>",
				desc = "toggle current line blame",
			},
			-- toggle deleted
			{ "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", desc = "toggle deleted" },
		})

		-- git hunks
		wk.add({
			{ "<leader>gh", group = "hunks" },
			{ "<leader>ghn", nextHunk, desc = "next hunk" },
			{ "<leader>ghp", prevHunk, desc = "prev hunk" },
			{ "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = "reset hunk" },

			{ "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "stage hunk" },
			-- undo stage hunk
			{ "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "undo stage hunk" },
		})

		-- Text object
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
	end,
})


