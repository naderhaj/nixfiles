local paths = require("nix-paths")

vim.cmd([[
  augroup RustMappings
  autocmd!
  autocmd FileType rust lua SetupRustMappings()
  augroup END
]])

function SetupRustMappings()
	local opts = { noremap = true, silent = true }
	vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp runnables<CR>", opts)
	vim.keymap.set("n", "<leader>re", "<cmd>RustLsp expandMacro<CR>", opts)
	vim.keymap.set("n", "<leader>rc", "<cmd>RustLsp openCargo<CR>", opts)
	vim.keymap.set("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>", opts)
end

vim.cmd([[
    autocmd filetype nix setlocal tabstop=2 shiftwidth=2 softtabstop=2
]])

local attach_keymaps = function(client, bufnr)
	local opts = { buffer = bufnr }

	-- goto
	vim.keymap.set("n", "<leader>lgD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "declaration" })
	vim.keymap.set("n", "<leader>lgd", vim.lsp.buf.definition, { buffer = bufnr, desc = "definition" })
	-- override the built-in text-search gd in LSP buffers
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "go to definition (LSP)" })
	vim.keymap.set("n", "<leader>lgi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "implementation" })
	vim.keymap.set("n", "<leader>lgr", vim.lsp.buf.references, { buffer = bufnr, desc = "references" })
	vim.keymap.set("n", "<leader>lgt", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "type definition" })
	vim.keymap.set("n", "<leader>lgn", function()
		vim.diagnostic.jump({ count = 1 })
	end, { buffer = bufnr, desc = "next diagnostic" })
	vim.keymap.set("n", "<leader>lgp", function()
		vim.diagnostic.jump({ count = -1 })
	end, { buffer = bufnr, desc = "previous diagnostic" })

	-- code action
	vim.keymap.set("n", "<leader>lca", vim.lsp.buf.code_action, opts)

	-- workspace
	vim.keymap.set("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, opts)
	vim.keymap.set("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, opts)
	vim.keymap.set("n", "<leader>lwl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, opts)

	-- hover & signature
	vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { buffer = bufnr, desc = "hover docs" })
	vim.keymap.set("n", "<leader>lsh", vim.lsp.buf.signature_help, opts)

	-- rename
	vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, { buffer = bufnr, desc = "rename symbol" })

	-- inline type / parameter-name hints, off by default
	vim.keymap.set("n", "<leader>li", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
	end, { buffer = bufnr, desc = "toggle inlay hints" })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
-- for nvim-ufo; must be set before the servers below copy `capabilities`
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- Rust config
vim.g.rustaceanvim = {
	server = {
		capabilities = capabilities,
		on_attach = attach_keymaps,
		cmd = { paths.rust_analyzer },
		default_settings = {
			["rust-analyzer"] = {
				experimental = {
					procAttrMacros = true,
				},
			},
		},
	},
}

-- in-process LSP mode, so Cargo.toml completion works without an nvim-cmp source
require("crates").setup({ lsp = { enabled = true, completion = true, actions = true, hover = true } })

-- Python config
vim.lsp.config["basedpyright"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	cmd = { paths.basedpyright, "--stdio" },
	filetypes = { "python" },
	-- root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	-- settings = {
	-- 	python = {
	-- 		analysis = {
	-- 			autoSearchPaths = true,
	-- 			useLibraryCodeForTypes = true,
	-- 			diagnosticMode = "workspace",
	-- 			typeCheckingMode = "off",
	-- 		},
	-- 	},
	-- },
}
vim.lsp.enable("basedpyright")

-- Ruff as a language server: inline lint diagnostics + quick fixes
-- (fix all, organize imports). Formatting stays with conform.
vim.lsp.config["ruff"] = {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		attach_keymaps(client, bufnr)
		-- leave hover to basedpyright, which has the type information
		client.server_capabilities.hoverProvider = false
	end,
	cmd = { paths.ruff, "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
}
vim.lsp.enable("ruff")

-- Nix config
vim.lsp.config["nil_ls"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		["nil"] = {
			formatting = {
				command = { paths.nixpkgs_fmt },
			},
			diagnostics = {
				ignored = { "uri_literal" },
				excludedFiles = {},
			},
			nix = {
				flake = {
					autoArchive = false,
					autoEvalInputs = false,
					nixpkgsInputName = "nixpkgs",
				},
			},
		},
	},
	cmd = { paths.nil_ls },
}
vim.lsp.enable("nil_ls")

-- Scala nvim-metals config
metals_config = require("metals").bare_config()
metals_config.capabilities = capabilities
-- Metals keys exist only in Scala buffers, on top of the shared LSP keys
metals_config.on_attach = function(client, bufnr)
	attach_keymaps(client, bufnr)
	require("which-key").add({
		buffer = bufnr,
		{ "<leader>lm", group = "metals" },
		{ "<leader>lmc", function() require("metals").commands() end, desc = "metals commands" },
		{
			"<leader>lmi",
			function() require("metals").toggle_setting("showImplicitArguments") end,
			desc = "toggle implicit args",
		},
		{ "<leader>lmw", function() require("metals").worksheet_hover() end, desc = "worksheet hover" },
		{ "<leader>lmd", function() require("metals").open_all_diagnostics() end, desc = "all diagnostics" },
	})
end

metals_config.settings = {
	metalsBinaryPath = paths.metals,
	showImplicitArguments = true,
	showImplicitConversionsAndClasses = true,
	showInferredType = true,
	excludedPackages = {
		"akka.actor.typed.javadsl",
		"com.github.swagger.akka.javadsl",
	},
}

metals_config.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx)
	vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, {
		virtual_text = {
			prefix = "",
		},
	})
end

-- without doing this, autocommands that deal with filetypes prohibit messages from being shown
vim.opt_global.shortmess:remove("F")

vim.cmd([[augroup lsp]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType scala,sbt lua require('metals').initialize_or_attach(metals_config)]])
vim.cmd([[augroup end]])

-- TS config
vim.lsp.config["ts_ls"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	cmd = { paths.typescript_language_server, "--stdio" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	-- ts_ls only sends inlay hints when asked to
	settings = (function()
		local inlayHints = {
			includeInlayParameterNameHints = "all",
			includeInlayVariableTypeHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
		}
		return {
			typescript = { inlayHints = inlayHints },
			javascript = { inlayHints = inlayHints },
		}
	end)(),
}
vim.lsp.enable("ts_ls")

-- HTML config
vim.lsp.config["html"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "html" },
	cmd = { paths.html_language_server, "--stdio" },
	root_markers = { "package.json", ".git" },
}
vim.lsp.enable("html")

-- C Config
vim.lsp.config["clangd"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	cmd = { paths.clangd, "--offset-encoding=utf-16" },
	root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
}
vim.lsp.enable("clangd")

-- Go Config
vim.lsp.config["gopls"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	cmd = { paths.gopls, "serve" },
	root_markers = { "go.mod", "go.work", ".git" },
	-- gopls only sends inlay hints when asked to
	settings = {
		gopls = {
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}
vim.lsp.enable("gopls")

-- Lua Config
vim.lsp.config["lua_ls"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git" },
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = { version = "LuaJIT" },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
		})
	end,
	settings = {
		Lua = {},
	},
}
vim.lsp.enable("lua_ls")

-- Java Config (jdtls)
vim.lsp.config["jdtls"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	filetypes = { "java" },
	cmd = { paths.jdtls },
	root_markers = { "build.gradle", "pom.xml", "settings.gradle", ".git" },
	settings = {
		java = {
			eclipse = { downloadSources = true },
			maven = { downloadSources = true },
			implementationsCodeLens = { enabled = true },
			referencesCodeLens = { enabled = true },
			references = { includeDecompiledSources = true },
			format = { enabled = true },
		},
		signatureHelp = { enabled = true },
		completion = {
			favoriteStaticMembers = {
				"org.hamcrest.MatcherAssert.assertThat",
				"org.hamcrest.Matchers.*",
				"org.hamcrest.CoreMatchers.*",
				"org.junit.jupiter.api.Assertions.*",
				"java.util.Objects.requireNonNull",
				"java.util.Objects.requireNonNullElse",
				"org.mockito.Mockito.*",
			},
		},
	},
}
vim.lsp.enable("jdtls")

-- Helm: nvim has no built-in detection. templates/*.yaml only counts as Helm
-- inside a chart (a Chart.yaml above it); otherwise it stays plain YAML.
vim.filetype.add({
	pattern = {
		[".*/templates/.*%.ya?ml"] = function(path)
			return vim.fs.root(path, "Chart.yaml") and "helm" or nil
		end,
		[".*/templates/.*%.tpl"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
	},
})

-- YAML Config
vim.lsp.config["yamlls"] = {
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		attach_keymaps(client, bufnr)
		-- apply the Kubernetes schema to any file that looks like a manifest,
		-- wherever it lives
		local head = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, 50, false), "\n")
		if head:match("apiVersion:") and head:match("kind:") then
			local schemas = client.settings.yaml.schemas
			schemas.kubernetes = schemas.kubernetes or {}
			table.insert(schemas.kubernetes, vim.api.nvim_buf_get_name(bufnr))
			client:notify("workspace/didChangeConfiguration", { settings = client.settings })
		end
	end,
	cmd = { paths.yaml_language_server, "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose" },
	root_markers = { ".git" },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			format = { enable = false }, -- don't let format-on-save rewrite manifests
			schemaStore = { enable = false, url = "" }, -- use SchemaStore.nvim's list instead
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}
vim.lsp.enable("yamlls")

-- Helm Config
vim.lsp.config["helm_ls"] = {
	capabilities = capabilities,
	on_attach = attach_keymaps,
	cmd = { paths.helm_ls, "serve" },
	filetypes = { "helm" },
	root_markers = { "Chart.yaml" },
	settings = {
		["helm-ls"] = {
			-- helm-ls runs yaml-language-server internally for the YAML parts of templates
			yamlls = { path = paths.yaml_language_server },
		},
	},
}
vim.lsp.enable("helm_ls")

require("telescope").load_extension("ui-select")

-- Display number of folded lines
local ufo_handler = function(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local suffix = ("  %d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, "MoreMsg" })
	return newVirtText
end

require("ufo").setup({
	fold_virt_text_handler = ufo_handler,
})

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
