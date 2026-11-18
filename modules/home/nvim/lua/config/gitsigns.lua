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
				gs.nav_hunk("next")
			end)
			return "<Ignore>"
		end

		local function prevHunk()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.nav_hunk("prev")
			end)
			return "<Ignore>"
		end

		wk.add({
			mode = "n",
			buffer = bufnr,
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
			buffer = bufnr,
			{ "<leader>gt", group = "toggle" },
			-- toggle current line blame
			{
				"<leader>gtb",
				"<cmd>Gitsigns toggle_current_line_blame<cr>",
				desc = "toggle current line blame",
			},
			-- toggle deleted
			{ "<leader>gtd", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "show deleted (inline hunk)" },
			{ "<leader>gtl", "<cmd>Gitsigns toggle_linehl<cr>", desc = "toggle line highlight" },
			{ "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "toggle word diff" },
		})

		-- git hunks
		wk.add({
			buffer = bufnr,
			{ "<leader>gh", group = "hunks" },
			{ "<leader>ghn", nextHunk, desc = "next hunk", expr = true },
			{ "<leader>ghp", prevHunk, desc = "prev hunk", expr = true },
			{ "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = "reset hunk" },

			{ "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "stage hunk" },
			-- undo stage hunk
			{ "<leader>ghu", "<cmd>Gitsigns stage_hunk<cr>", desc = "unstage hunk (toggle)" },
			{ "<leader>ghv", "<cmd>Gitsigns preview_hunk<cr>", desc = "preview hunk" },
			{ "<leader>ghl", "<cmd>Gitsigns setloclist<cr>", desc = "list file hunks (loclist)" },
			{ "<leader>ghq", "<cmd>Gitsigns setqflist all<cr>", desc = "list repo hunks (quickfix)" },
		})

		-- Text object
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
	end,
})


