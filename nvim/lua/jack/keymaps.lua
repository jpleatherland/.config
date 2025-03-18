-- set leader jk to esc
vim.keymap.set({ "i", "v" }, "<leader>jk", "<Esc>")

-- pane navigation
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>l", "<C-w>l")
vim.keymap.set("n", "<leader>k", "<C-w>k")

-- pane resize
vim.keymap.set("n", "<leader>u", "10<C-w><")
vim.keymap.set("n", "<leader>o", "10<C-w>>")
vim.keymap.set("n", "<leader>U", "<C-w>>")
vim.keymap.set("n", "<leader>O", "<C-w><")
vim.keymap.set("n", "<leader>.", "<C-w>+")
vim.keymap.set("n", "<leader>m", "<C-w>-")
vim.keymap.set("n", "<leader>c", "gcc")

-- variable rename
vim.keymap.set("n", "<leader>r", "yiw[{V%::s/<C-r>///g<left><left>") --local
vim.keymap.set("n", "<leader>R", "gD:%s/<C-R><C-W>///g<left><left>") --global

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- commenting this out while trying oil.nvim
-- vim.keymap.set("n", "<leader>pv", ":Ex<CR>")
