require("toggleterm").setup({
	direction = "float",
	open_mapping = [[<c-\>]],
	-- leave <c-\> unbound in terminal mode so <c-\><c-n> reaches normal mode
	terminal_mappings = false,
})
