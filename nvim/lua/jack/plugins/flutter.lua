return {
	"akinsho/flutter-tools.nvim",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- optional for vim.ui.select
	},
	ft = { "dart" },
	cmd = { "FlutterRun", "FlutterDevices", "FlutterOutline", "FlutterReload", "FlutterRestart", "Flutter" },
	config = function()
		require("flutter-tools").setup({})
	end,
}
