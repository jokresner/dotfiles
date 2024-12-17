return {
	"michaelrommel/nvim-silicon",
	lazy = true,
	cmd = "Silicon",
	config = function()
		require("silicon").setup({
			-- Configuration here, or leave empty to use defaults
			font = "FiraCode Nerd Font=34",
			theme = "Dracula",
		})
	end,
}

-- vim: ts=2 sts=2 sw=2 et
