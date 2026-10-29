-- Tint dadbod-ui windows by environment so prod is impossible to miss.
-- Matches on the DBUI connection name (b:dbui_db_key_name) and the URL (b:db).
local db_envs = {
	{ pattern = "prod", label = "PROD", hl = "DbEnvProd", bg = "#3b1a1a", badge = "#e06c75", confirm = true },
	{ pattern = "stag", label = "STAGING", hl = "DbEnvStaging", bg = "#1a2540", badge = "#61afef" },
	{ pattern = "preview", label = "PREVIEW", hl = "DbEnvLocal", bg = "#1a3320", badge = "#98c379" },
	-- Preview DBs are named "pr_<number>".
	{ pattern = "pr_", label = "PREVIEW", hl = "DbEnvLocal", bg = "#1a3320", badge = "#98c379" },
	{ pattern = "local", label = "LOCAL", hl = "DbEnvLocal", bg = "#1a3320", badge = "#98c379" },
}

-- Statements that need a y/N on environments with `confirm = true`.
local risky_keywords = { "UPDATE", "DELETE", "DROP", "TRUNCATE", "ALTER" }

local function define_highlights()
	for _, env in ipairs(db_envs) do
		vim.api.nvim_set_hl(0, env.hl, { bg = env.bg })
		vim.api.nvim_set_hl(0, env.hl .. "Bar", { fg = "#1e2127", bg = env.badge, bold = true })
		vim.api.nvim_set_hl(0, env.hl .. "Drawer", { fg = env.badge, bold = true })
	end
end
define_highlights()

-- clear = true makes re-sourcing (:luafile) replace the autocmds instead of stacking them.
local group = vim.api.nvim_create_augroup("DbEnvTint", { clear = true })

-- Colorschemes clear custom groups; re-apply after any :colorscheme.
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_highlights })

-- Result (dbout) buffers only know the URL, so remember which env and
-- connection name each URL resolved to from its query buffer.
local info_by_url = {}

local function match_env(str)
	str = str:lower()
	for _, env in ipairs(db_envs) do
		if str:find(env.pattern, 1, true) then
			return env
		end
	end
end

-- Returns env, connection name (name may be nil for plain :DB buffers).
local function buffer_env(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end
	local key = vim.b[buf].dbui_db_key_name
	local db = vim.b[buf].db
	local url = type(db) == "table" and db.db_url or db
	if type(url) ~= "string" then
		url = nil
	end
	-- key_name is "<name>_<source>", e.g. "myapp-prod_g".
	local name = key and key:gsub("_[^_]+$", "")

	local cached = url and info_by_url[url]
	local env = (key and match_env(key)) or (cached and cached.env) or (url and match_env(url))
	name = name or (cached and cached.name)
	if env and url then
		info_by_url[url] = { env = env, name = name }
	end
	return env, name
end

local function apply(win)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	local env, name = buffer_env(vim.api.nvim_win_get_buf(win))
	if env then
		vim.wo[win].winhighlight = ("Normal:%s,NormalNC:%s,EndOfBuffer:%s"):format(env.hl, env.hl, env.hl)
		local title = name and (env.label .. " · " .. name) or env.label
		vim.wo[win].winbar = ("%%#%sBar#%%=\239\129\177 %s%%=%%*"):format(env.hl, title:gsub("%%", "%%%%"))
		vim.w[win].db_env_tinted = true
	elseif vim.w[win].db_env_tinted then
		-- Only reset windows we tinted; leave other plugins' options alone.
		vim.wo[win].winhighlight = ""
		vim.wo[win].winbar = ""
		vim.w[win].db_env_tinted = false
	end
end

-- Color connection rows in the DBUI drawer. Connections are the only
-- unindented rows that can contain a name, so `^\S` skips tables/queries.
local function apply_drawer(win)
	for _, id in ipairs(vim.w[win].db_env_matches or {}) do
		pcall(vim.fn.matchdelete, id, win)
	end
	local ids = {}
	for i, env in ipairs(db_envs) do
		-- Earlier entries win, matching match_env's precedence.
		local id = vim.fn.matchadd(env.hl .. "Drawer", [[\c^\S.*\V]] .. env.pattern .. [[\m.*]], 100 - i, -1, { window = win })
		table.insert(ids, id)
	end
	vim.w[win].db_env_matches = ids
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "FileType" }, {
	group = group,
	callback = function()
		-- dadbod-ui sets its buffer vars after the buffer is opened.
		local win = vim.api.nvim_get_current_win()
		vim.schedule(function()
			if not vim.api.nvim_win_is_valid(win) then
				return
			end
			if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dbui" then
				apply_drawer(win)
			else
				apply(win)
			end
		end)
	end,
})

vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "*DBExecutePost",
	callback = function()
		vim.schedule(function()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				apply(win)
			end
		end)
	end,
})

-- Blank out comments and string literals so keywords inside them don't count.
local function strip_sql(sql)
	sql = sql:gsub("/%*.-%*/", " "):gsub("%-%-[^\n]*", " ")
	sql = sql:gsub("'[^']*'", "''"):gsub('"[^"]*"', '""')
	return sql:upper()
end

local function has_word(s, word)
	return s:find("%f[%w_]" .. word .. "%f[^%w_]") ~= nil
end

-- Returns a warning message if the SQL contains risky statements, else nil.
local function risky_message(sql)
	local found, unbounded = {}, false
	for stmt in (strip_sql(sql) .. ";"):gmatch("([^;]*);") do
		for _, kw in ipairs(risky_keywords) do
			if has_word(stmt, kw) and not vim.tbl_contains(found, kw) then
				table.insert(found, kw)
			end
		end
		if (has_word(stmt, "UPDATE") or has_word(stmt, "DELETE")) and not has_word(stmt, "WHERE") then
			unbounded = true
		end
	end
	if #found == 0 then
		return nil
	end
	local msg = "Query contains: " .. table.concat(found, ", ")
	if unbounded then
		msg = msg .. "\n\n!!! UPDATE/DELETE WITHOUT WHERE: affects EVERY row !!!"
	end
	return msg
end

-- vim-dadbod writes the query to "<tmp>.<ext>" next to the "<tmp>.dbout"
-- output, except when it runs a saved, unmodified buffer straight from disk.
local function query_text(outfile)
	local base = outfile:gsub("%.[^./]+$", "")
	for _, f in ipairs(vim.fn.glob(vim.fn.fnameescape(base) .. ".*", true, true)) do
		if f ~= outfile then
			return table.concat(vim.fn.readfile(f), "\n")
		end
	end
	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

-- Called synchronously from DBExecutePre; returning false cancels the query.
function _G.db_env_confirm_execute(outfile)
	-- The output buffer carries the actual connection; the current buffer is
	-- the query buffer it was run from.
	local env, name = buffer_env(vim.fn.bufnr(outfile))
	if not env then
		env, name = buffer_env(vim.api.nvim_get_current_buf())
	end
	if not (env and env.confirm) then
		return true
	end
	local msg = risky_message(query_text(outfile))
	if not msg then
		return true
	end
	local where = name and (env.label .. " (" .. name .. ")") or env.label
	local ok = vim.fn.confirm("Run on " .. where .. "?\n\n" .. msg, "&Yes\n&No", 2, "Warning") == 1
	if not ok then
		-- Close the empty result window dadbod already opened.
		vim.schedule(function()
			local buf = vim.fn.bufnr(outfile)
			if buf > 0 then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end)
	end
	return ok
end

-- Must be Vimscript: only a Vim `throw` propagates out of doautocmd into
-- vim-dadbod's `catch /^DB: /`, which aborts the job before it starts.
vim.cmd([[
augroup DbEnvConfirm
  autocmd!
  autocmd User *DBExecutePre if !v:lua.db_env_confirm_execute(expand('<amatch>:h')) | throw 'DB: query cancelled' | endif
augroup END
]])

-- Used by the lualine badge in statusline.lua.
function _G.db_env_for_win(win)
	if not vim.api.nvim_win_is_valid(win) then
		return nil
	end
	return (buffer_env(vim.api.nvim_win_get_buf(win)))
end

-- Apply to already-open windows (matters when re-sourcing while iterating).
for _, win in ipairs(vim.api.nvim_list_wins()) do
	if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dbui" then
		apply_drawer(win)
	else
		apply(win)
	end
end
