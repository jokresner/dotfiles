return {
	"stevearc/oil.nvim",
	config = function()
		local oil = require("oil")
		oil.setup({
			default_file_explorer = true,
			columns = {
				"icon",
				"size",
			},
			win_options = {
				signcolumn = "yes",
				spell = true,
				list = true,
			},
			delete_to_trash = true,
			promt_save_on_select_new_entry = true,
			experimental_watch_for_changes = true,
			view_options = {
				show_hidden = true,
			},
		})

		vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
	end,
}

-- vim: ts=2 sts=2 sw=2 et
