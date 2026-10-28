local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Git
keymap("n", "<leader>gg", ":Git<CR>", opts)

-- :BranchDiff [base] — one diff tab per file changed on this branch (gt/gT to move).
-- Diffs from the merge-base with [base] (default origin/main), like a PR, so commits
-- that landed on base after you branched don't show up as reverted. Right side is
-- the working tree, so uncommitted changes are included and files stay editable.
vim.api.nvim_create_user_command("BranchDiff", function(cmd)
	local base = cmd.args ~= "" and cmd.args or "origin/main"
	local result = vim.system({ "git", "merge-base", base, "HEAD" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify("BranchDiff: no merge-base with " .. base .. "\n" .. (result.stderr or ""), vim.log.levels.ERROR)
		return
	end
	vim.cmd("Git difftool -y " .. vim.trim(result.stdout))
end, {
	nargs = "?",
	desc = "Diff current branch against its merge-base with a base branch",
	complete = function(lead)
		local refs = vim.fn.systemlist({ "git", "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" })
		return vim.tbl_filter(function(r)
			return vim.startswith(r, lead)
		end, refs)
	end,
})
vim.keymap.set("n", "<leader>gB", "<cmd>BranchDiff<CR>", { desc = "branch diff vs origin/main" })
