-- copilot, not a lua plugin
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--

-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	--Plugins can be added with a link (or for a github repo: 'owner/repo' link).
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	-- NOTE: Plugins can also be added by using a table,
	-- with the first argument being the link and the following
	-- keys can be used to configure plugin behavior/loading/etc.
	--
	-- Use `opts = {}` to force a plugin to be loaded.
	--

	-- modular approach: using `require 'path/name'` will
	-- include a plugin definition from file lua/path/name.lua

	-- Adds git related signs to the gutter, as well as utilities for managing changes
	require("jack/plugins/gitsigns"),

	-- search and much more
	require("jack/plugins/telescope"),

	-- lsp config
	require("jack/plugins/nvim_lspconfig"),

	-- autoformat
	require("jack/plugins/conform"),

	-- autocomplete
	require("jack/plugins/nvim_cmp"),

	-- theme
	require("jack/plugins/aura"),

	-- Highlight todo, notes, etc in comments
	require("jack/plugins/todo_comments"),

	-- genenral nvim improvements
	require("jack/plugins/mini"),

	-- "gc" to comment visual regions/lines
	-- "gcc" to toggle comment line
	require("jack/plugins/visualcomment"),

	-- treesitter
	require("jack/plugins/treesitter"),

	-- directory & file navigation
	require("jack/plugins/oil"),

	-- debugging
	require("jack/plugins/debug"),

	-- flutter
	require("jack/plugins/flutter"),

	-- indent_line
	require("jack/plugins/indent_line"),

	-- go multipack
	require("jack/plugins/go"),

	-- copilot chat
	require("jack/plugins/copilot_chat"),

	-- smooth cursor
	-- require("jack/plugins/smear_cursor"),
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
