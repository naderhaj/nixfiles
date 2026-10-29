-- Headless smoke test for the Neovim config, run by scripts/nvim-test.sh.
-- Loaded with --cmd, i.e. before init.lua: it records which config modules
-- init.lua requires, then runs the checks on VimEnter. Prints one line per
-- check and exits non-zero if any fail.

-- package.loaded can't tell us afterwards: some plugins (onedark) clear their
-- own entries from it, ours included.
local required = {}
local original_require = require
_G.require = function(name)
	local mod = original_require(name)
	if type(name) == "string" and name:match("^config%.") then
		required[name] = true
	end
	return mod
end

local root = assert(vim.env.NVIM_TEST_ROOT, "NVIM_TEST_ROOT not set")
local failures = 0

local function check(name, ok, detail)
	io.stdout:write(("%s %s%s\n"):format(ok and "ok  " or "FAIL", name, (not ok and detail) and (" -- " .. detail) or ""))
	if not ok then
		failures = failures + 1
	end
end

local function section(title)
	io.stdout:write(("\n## %s\n"):format(title))
end

-- Sample project: one file per language, unformatted so the formatters have
-- something to do. `.git` makes it the root for every server's root_markers.
local samples = {
	{ file = "x.py", ft = "python", lsp = { "basedpyright", "ruff" }, text = "x=1\n" },
	{ file = "x.nix", ft = "nix", lsp = { "nil_ls" }, text = "{a=1;}\n" },
	{ file = "x.lua", ft = "lua", lsp = { "lua_ls" }, text = "local x=1\nreturn x\n" },
	{ file = "x.ts", ft = "typescript", lsp = { "ts_ls" }, text = "const a=1\n" },
	{ file = "main.go", ft = "go", lsp = { "gopls" }, text = "package main\n" },
	{ file = "x.c", ft = "c", lsp = { "clangd" }, text = "int main(void) { return 0; }\n" },
	{ file = "x.yaml", ft = "yaml", lsp = { "yamlls" }, text = "a: 1\n" },
	{ file = "x.html", ft = "html", lsp = { "html" }, text = "<p>hi</p>\n" },
	{ file = "x.tf", ft = "terraform", lsp = { "terraformls" }, text = 'variable "a" {}\n' },
}
local formatted = { python = true, nix = true, lua = true, typescript = true }

local function run()
	section("startup")
	local messages = vim.api.nvim_exec2("messages", { output = true }).output
	-- Not v:errmsg: it's also set by errors that plugins catch themselves.
	check("no errors during startup", not messages:match("E%d+:"), messages)
	if package.loaded.notify then
		local errors = vim.tbl_filter(function(n)
			return n.level == "ERROR"
		end, require("notify").history())
		check(
			"no error notifications",
			#errors == 0,
			table.concat(vim.tbl_map(function(n)
				return table.concat(n.message, " ")
			end, errors), "; ")
		)
	end

	-- Every module under lua/config/ must be required by init.lua.
	local config_dir = root .. "/modules/home/nvim/lua/config"
	for path, kind in vim.fs.dir(config_dir, { depth = 5 }) do
		if kind == "file" and path:match("%.lua$") then
			local mod = "config." .. path:gsub("%.lua$", ""):gsub("/", ".")
			check("loaded " .. mod, required[mod], "not required by init.lua, or failed to load")
		end
	end
	check("telescope fzf extension", pcall(require("telescope").load_extension, "fzf"))

	section("executables")
	local exes = { "rust-analyzer", vim.g.nix_metals_path }
	for name in pairs(vim.lsp._enabled_configs) do
		local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
		if type(cmd) == "table" then
			table.insert(exes, cmd[1])
		end
	end
	table.sort(exes)
	for _, exe in ipairs(exes) do
		check(exe, vim.fn.executable(exe) == 1, "not on PATH")
	end
	for _, name in ipairs({ "ruff", "stylua", "prettier", "nixfmt" }) do
		local info = require("conform").get_formatter_info(name)
		check("formatter " .. name, info.available, info.available_msg)
	end

	section("treesitter parsers")
	local seen = {}
	for _, so in ipairs(vim.api.nvim_get_runtime_file("parser/*.so", true)) do
		local lang = vim.fn.fnamemodify(so, ":t:r")
		if not seen[lang] then
			seen[lang] = true
			local ok, err = pcall(vim.treesitter.language.add, lang)
			check(lang, ok, tostring(err))
		end
	end

	section("languages")
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir .. "/.git", "p")
	local bufs = {}
	for _, s in ipairs(samples) do
		local path = dir .. "/" .. s.file
		vim.fn.writefile(vim.split(s.text, "\n", { trimempty = true }), path)
		vim.cmd("silent edit " .. vim.fn.fnameescape(path))
		bufs[s.file] = vim.api.nvim_get_current_buf()
	end

	local function attached(buf, name)
		local client = vim.lsp.get_clients({ bufnr = buf, name = name })[1]
		return client ~= nil and client.initialized
	end
	vim.wait(60000, function()
		for _, s in ipairs(samples) do
			for _, name in ipairs(s.lsp) do
				if not attached(bufs[s.file], name) then
					return false
				end
			end
		end
		return true
	end, 200)

	for _, s in ipairs(samples) do
		local buf = bufs[s.file]
		check(s.file .. " filetype", vim.bo[buf].filetype == s.ft, vim.bo[buf].filetype)
		check(s.file .. " highlighting", vim.treesitter.highlighter.active[buf] ~= nil, "treesitter not started")
		for _, name in ipairs(s.lsp) do
			check(s.file .. " lsp " .. name, attached(buf, name), "did not attach within 60s")
		end
		if formatted[s.ft] then
			local before = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
			require("conform").format({ bufnr = buf, async = false, timeout_ms = 10000 })
			local after = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
			check(s.file .. " formats", after ~= before, "buffer unchanged")
		end
	end
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = vim.schedule_wrap(function()
		local ok, err = xpcall(run, debug.traceback)
		if not ok then
			check("test script", false, err)
		end
		io.stdout:write(("\n%d failure(s)\n"):format(failures))
		vim.cmd(failures == 0 and "qall!" or "cquit 1")
	end),
})
