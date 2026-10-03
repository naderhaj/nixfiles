-- Set variable so other plugins can register mappings
local wk = require("which-key")

-- Set up which-key
wk.setup({})

-- LSP
wk.add({
	mode = "n",
	{ "<leader>l", group = "lsp" },
})

-- LSP subgroups
wk.add({ mode = "n", { "<leader>lc", group = "code action" } })
wk.add({ mode = "n", { "<leader>lg", group = "goto" } })
wk.add({ mode = "n", { "<leader>ls", group = "signature" } })
wk.add({ mode = "n", { "<leader>lt", group = "trouble" } })
wk.add({ mode = "n", { "<leader>lw", group = "workspace" } })

-- Trouble
wk.add({ mode = "n", { "<leader>x", group = "trouble" } })

-- b buffers
wk.add({ mode = "n", { "<leader>b", group = "buffers" } })


-- f telescope
wk.add({ mode = "n", { "<leader>f", group = "telescope" } })

-- j json
wk.add({ mode = "n", { "<leader>j", group = "json" } })

-- n neoclip
wk.add({ mode = "n", { "<leader>n", group = "neoclip" } })

-- s substitute
wk.add({ mode = "n", { "<leader>s", group = "substitute" } })

-- t tree
wk.add({ mode = "n", { "<leader>t", group = "tree" } })
