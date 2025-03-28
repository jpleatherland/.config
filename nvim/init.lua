-- set leader to \, pv to file tree and \jk to esc
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

require("jack/lazy-bootstrap")
require("jack/keymaps")
require("jack/options")
require("jack/autocommands")
require("jack/lazy-plugins")

-- pane resize
vim.keymap.set("n", "<leader>u", "10<C-w><")
vim.keymap.set("n", "<leader>o", "10<C-w>>")
vim.keymap.set("n", "<leader>U", "<C-w>>")
vim.keymap.set("n", "<leader>O", "<C-w><")
vim.keymap.set("n", "<leader>.", "<C-w>+")
vim.keymap.set("n", "<leader>m", "<C-w>-")

-- variable rename
vim.keymap.set("n", "<leader>r", "yiw[{V%::s/<C-r>///g<left><left>") --local
vim.keymap.set("n", "<leader>R", "gD:%s/<C-R><C-W>///g<left><left>") --global

-- set line numbers to hybrid
vim.opt.number = true
vim.opt.relativenumber = true

-- default spacing
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.backspace = { "start", "eol", "indent" }

-- code folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

vim.opt.ruler = false

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
