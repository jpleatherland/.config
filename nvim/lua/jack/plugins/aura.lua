return {
	{ -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		--"techtuner/aura-neovim",
		--priority = 1000, -- Make sure to load this before all the other start plugins.
		--init = function()
		-- Load the colorscheme here.
		-- Like many other themes, this one has different styles, and you could load
		-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
		--vim.cmd.colorscheme("aura")
		--	vim.opt.termguicolors = true

		-- You can configure highlights by doing something like:
		--	vim.cmd.hi("Comment gui=none")
		--end,
		--
		"baliestri/aura-theme",
		lazy = false,
		priority = 1000,
		config = function(plugin)
			vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
			vim.cmd([[colorscheme aura-soft-dark]])
		end,
	},
}
