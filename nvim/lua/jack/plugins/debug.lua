return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"leoluz/nvim-dap-go",
			"mxsdev/nvim-dap-vscode-js",
			{
				"microsoft/vscode-js-debug",
				version = "1.x",
				build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
			},
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")
			local dapgo = require("dap-go")
			local js_based_languages = { "javascript", "typescript" }
			local json = require("dap.ext.vscode").json_decode

			local function load_launch_json()
				local file = vim.fn.getcwd() .. "/.vscode/launch.json"
				if vim.fn.filereadable(file) == 1 then
					local status, launch_data = pcall(json(table.concat(vim.fn.readfile(file), "\n")))
					if not status then
						print("Failed to parse launch.json")
						return
					end

					if launch_data and launch_data.configurations then
						for _, config in ipairs(launch_data.configurations) do
							if config.type and dap.adapters[config.type] then
								dap.configurations[config.type] = dap.configurations[config.type] or {}
								table.insert(dap.configurations[config.type], config)
							end
						end
					end

					if launch_data and launch_data.compounds then
						for _, compound in ipairs(launch_data.compounds) do
							dap.configurations[compound.name] = {
								type = "compound",
								name = compound.name,
								configurations = compound.configurations,
							}
						end
					end
				else
					print("No launch.json found in .vscode directory")
				end
			end

			---@diagnostic disable: undefined-field
			local function run_compound(name)
				local compound = dap.configurations[name]
				if not compound or compound.type ~= "compound" then
					print("No compound named " .. name)
					return
				end

				for _, config_name in ipairs(compound.configurations) do
					local config = nil
					for _, v in pairs(dap.configurations) do
						for _, c in ipairs(v) do
							if c.name == config_name then
								config = c
								break
							end
						end
					end

					if config then
						print("Starting " .. config_name)
						dap.run(config)
					else
						print("Configuration not found: " .. config_name)
					end
				end
			end

			require("dapui").setup()
			require("dap-go").setup()
			require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")

			require("nvim-dap-virtual-text").setup({})
			require("dap-vscode-js").setup({
				node_path = "/home/leathj/.nvm/versions/node/v18.20.1/bin/node",
				debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),
				adapters = { "pwa-node", "pwa-chrome" },
			})

			load_launch_json()

			-- Handled by nvim-dap-go
			-- dap.adapters.go = {
			--   type = "server",
			--   port = "${port}",
			--   executable = {
			--     command = "dlv",
			--     args = { "dap", "-l", "127.0.0.1:${port}" },
			--   },
			-- }

			vim.keymap.set("n", "<space>db", dap.toggle_breakpoint)
			vim.keymap.set("n", "<space>dtc", dap.run_to_cursor)
			vim.keymap.set("n", "<leader>dc", function()
				if not dap.configurations then
					print("No DAP configurations found!")
					return
				end

				-- Collect available compound names
				local compounds = {}
				for name, config in pairs(dap.configurations) do
					if type(config) == "table" and config.type == "compound" then
						table.insert(compounds, name)
					end
				end

				-- If no compounds exist, exit
				if #compounds == 0 then
					print("No launch compounds found in launch.json")
					return
				end

				-- Let user pick a compound
				vim.ui.select(compounds, { prompt = "Select a compound to debug:" }, function(choice)
					if choice then
						run_compound(choice)
					end
				end)
			end)
			vim.keymap.set("n", "<leader>dn", function()
				local bufs = vim.api.nvim_list_bufs()
				local dap_repls = {}

				-- Find all buffers with "DAP REPL" in their name or empty ones (sometimes DAP REPL has no name)
				for _, buf in ipairs(bufs) do
					local buf_name = vim.api.nvim_buf_get_name(buf)
					local buf_type = vim.api.nvim_buf_get_option(buf, "buftype")

					-- Check if it's a DAP REPL (matches name OR is an unnamed terminal-like buffer)
					if buf_name:match("DAP") or buf_type == "terminal" then
						table.insert(dap_repls, buf)
					end
				end

				-- Cycle through found REPL buffers
				if #dap_repls > 1 then
					local current = vim.api.nvim_get_current_buf()
					for i, buf in ipairs(dap_repls) do
						if buf == current then
							local next_buf = dap_repls[(i % #dap_repls) + 1]
							vim.api.nvim_set_current_buf(next_buf)
							return
						end
					end
				elseif #dap_repls == 1 then
					print("Only one DAP REPL buffer found")
				else
					print("No DAP REPL buffers found")
				end
			end)

			-- Eval var under cursor
			vim.keymap.set("n", "<space>?", function()
				require("dapui").eval(nil, { enter = true })
			end)

			vim.keymap.set("n", "<F3>", dap.continue)
			vim.keymap.set("n", "<F6>", dap.step_into)
			vim.keymap.set("n", "<F7>", dap.step_over)
			vim.keymap.set("n", "<F2>", dap.step_out)
			vim.keymap.set("n", "<F5>", dap.step_back)
			vim.keymap.set("n", "<F4>", dap.restart)
			vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
			vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#61afef", bg = "#31353f" })
			vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#98c379", bg = "#31353f" })

			vim.fn.sign_define(
				"DapBreakpoint",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			)
			vim.fn.sign_define(
				"DapBreakpointCondition",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			)
			vim.fn.sign_define(
				"DapBreakpointRejected",
				{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
			)
			vim.fn.sign_define(
				"DapLogPoint",
				{ text = "", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
			)
			vim.fn.sign_define(
				"DapStopped",
				{ text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" }
			)
			vim.keymap.set("n", "<F8>", ui.toggle)

			vim.keymap.set("n", "<leader>dgt", function()
				dapgo.debug_test()
			end)

			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
			for _, language in ipairs(js_based_languages) do
				require("dap").configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = 'Start Chrome with "localhost"',
						url = "http://localhost:3000",
						webRoot = "${workspaceFolder}",
						userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
					},
				}
			end
		end,
	},
}
