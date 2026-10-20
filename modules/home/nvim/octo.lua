-- octo.nvim: GitHub PR review. Every key lives under <leader>o, and only
-- harmless actions are mapped. Merge, close, approve, request changes, delete,
-- discard and CI rerun/cancel have no key on purpose — do them in the browser
-- (<leader>ob) or with an explicit :Octo command.

-- shared mappings
local nav = {
	select_next_entry = { lhs = "]q", desc = "next file" },
	select_prev_entry = { lhs = "[q", desc = "prev file" },
	select_first_entry = { lhs = "[Q", desc = "first file" },
	select_last_entry = { lhs = "]Q", desc = "last file" },
	select_next_unviewed_entry = { lhs = "]u", desc = "next unviewed file" },
	select_prev_unviewed_entry = { lhs = "[u", desc = "prev unviewed file" },
	close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
}
local files = {
	focus_files = { lhs = "<leader>of", desc = "focus file panel" },
	toggle_files = { lhs = "<leader>oF", desc = "toggle file panel" },
	toggle_viewed = { lhs = "<leader>ov", desc = "toggle file viewed" },
	submit_review = { lhs = "<leader>oS", desc = "open submit window" },
}
local thread = {
	add_comment = { lhs = "<leader>oc", desc = "add comment" },
	add_reply = { lhs = "<leader>oa", desc = "reply to thread" },
	resolve_thread = { lhs = "<leader>ot", desc = "resolve thread" },
	unresolve_thread = { lhs = "<leader>oT", desc = "unresolve thread" },
	next_comment = { lhs = "]c", desc = "next comment" },
	prev_comment = { lhs = "[c", desc = "prev comment" },
}
local web = {
	open_in_browser = { lhs = "<leader>ob", desc = "open in browser" },
	copy_url = { lhs = "<leader>oy", desc = "copy url" },
}
-- unmapped: blank where octo skips blank keys (buffer mappings), an untypeable
-- <Plug> key where it would pass "" to vim.keymap.set (pickers, runs buffer)
local off = { lhs = "" }
local function plug(name)
	return { lhs = "<Plug>(octo-off-" .. name .. ")" }
end

require("octo").setup({
	picker = "telescope",
	enable_builtin = false,
	-- right side of a review is the real file (LSP, gitsigns, treesitter), when
	-- on the PR branch; review start offers to checkout if not
	use_local_fs = true,
	mappings_disable_default = true,
	picker_config = {
		mappings = {
			open_in_browser = { lhs = "<C-b>", desc = "open in browser" },
			copy_url = { lhs = "<C-y>", desc = "copy url" },
			copy_sha = { lhs = "<C-e>", desc = "copy commit sha" },
			checkout_pr = plug("checkout"),
			merge_pr = plug("merge"),
		},
	},
	mappings = {
		pull_request = vim.tbl_extend("error", thread, web, {
			show_pr_diff = { lhs = "<leader>od", desc = "show PR diff" },
			list_changed_files = { lhs = "<leader>ol", desc = "list changed files" },
			checkout_pr = { lhs = "<leader>ok", desc = "checkout PR locally" },
			goto_file = { lhs = "gf", desc = "go to file" },
		}),
		issue = vim.tbl_extend("error", web, {
			add_comment = { lhs = "<leader>oc", desc = "add comment" },
			add_reply = { lhs = "<leader>oa", desc = "reply" },
			next_comment = { lhs = "]c", desc = "next comment" },
			prev_comment = { lhs = "[c", desc = "prev comment" },
		}),
		review_thread = vim.tbl_extend("error", thread, nav, {
			add_suggestion = { lhs = "<leader>og", desc = "add suggestion" },
		}),
		review_diff = vim.tbl_extend("error", nav, files, {
			add_review_comment = { lhs = "<leader>oc", desc = "add review comment", mode = { "n", "x" } },
			add_review_suggestion = { lhs = "<leader>og", desc = "add review suggestion", mode = { "n", "x" } },
			next_thread = { lhs = "]t", desc = "next thread" },
			prev_thread = { lhs = "[t", desc = "prev thread" },
			goto_file = { lhs = "gf", desc = "go to file" },
		}),
		file_panel = vim.tbl_extend("error", nav, files, {
			next_entry = { lhs = "j", desc = "next entry" },
			prev_entry = { lhs = "k", desc = "prev entry" },
			select_entry = { lhs = "<cr>", desc = "open file" },
			refresh_files = { lhs = "R", desc = "refresh files" },
		}),
		submit_win = {
			comment_review = { lhs = "<leader>oS", desc = "post review as comment" },
			close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
			-- the submit window header reads these two, so they must exist
			approve_review = off,
			request_changes = off,
		},
		-- mappings_disable_default drops these tables, but octo indexes every
		-- key unconditionally, so all of them must be defined
		runs = vim.tbl_extend("error", web, {
			expand_step = { lhs = "o", desc = "expand step" },
			next_step = { lhs = "]s", desc = "next step" },
			prev_step = { lhs = "[s", desc = "prev step" },
			next_job = { lhs = "]j", desc = "next job" },
			prev_job = { lhs = "[j", desc = "prev job" },
			refresh = { lhs = "<C-r>", desc = "refresh" },
			rerun = plug("rerun"),
			rerun_failed = plug("rerun-failed"),
			cancel = plug("cancel"),
		}),
		notification = {
			read = plug("read"),
			done = plug("done"),
			unsubscribe = plug("unsubscribe"),
		},
	},
})

-- global entry points
vim.keymap.set("n", "<leader>op", "<cmd>Octo pr list<CR>", { desc = "PR list" })
vim.keymap.set(
	"n",
	"<leader>or",
	"<cmd>Octo search is:pr is:open review-requested:@me<CR>",
	{ desc = "PRs awaiting my review" }
)
vim.keymap.set("n", "<leader>os", "<cmd>Octo review start<CR>", { desc = "start review" })
vim.keymap.set("n", "<leader>oR", "<cmd>Octo review resume<CR>", { desc = "resume review" })
vim.keymap.set("n", "<leader>oP", "<cmd>Octo review comments<CR>", { desc = "pending review comments" })
vim.keymap.set("n", "<leader>oi", "<cmd>Octo issue list<CR>", { desc = "issue list" })
vim.keymap.set("n", "<leader>on", "<cmd>Octo notification list<CR>", { desc = "notifications" })
