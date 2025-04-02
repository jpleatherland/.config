return {
	-- NOTE: Yes, you can install new plugins here!
	"mfussenegger/nvim-dap",
	-- NOTE: And you can specify dependencies as well
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",

		-- Required dependency for nvim-dap-ui
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"microsoft/vscode-js-debug",
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- Add your own debuggers here
		"leoluz/nvim-dap-go",
		"mxsdev/nvim-dap-vscode-js",
		"mfussenegger/nvim-dap-python",
		"rcarriga/cmp-dap", -- Optional: Autocomplete support in dap REPL
	},
	lazy = false,
	keys = {
		-- Basic debugging keymaps, feel free to change to your liking!
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Start/Continue",
		},
		{
			"<F6>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<F3>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<F1>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Set Breakpoint",
		},
		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		{
			"<F7>",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: See last session result.",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dap.adapters.node = dap.adapters["pwa-node"]

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				"delve", -- Go
				"js-debug-adapter", -- Javascript / Typescript / Node
				"debugpy", -- Python
			},
		})

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		-- Change breakpoint icons
		vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
		vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
		local breakpoint_icons = vim.g.have_nerd_font
				and {
					Breakpoint = "",
					BreakpointCondition = "",
					BreakpointRejected = "",
					LogPoint = "",
					Stopped = "",
				}
			or {
				Breakpoint = "●",
				BreakpointCondition = "⊜",
				BreakpointRejected = "⊘",
				LogPoint = "◆",
				Stopped = "⭔",
			}
		for type, icon in pairs(breakpoint_icons) do
			local tp = "Dap" .. type
			local hl = (type == "Stopped") and "DapStop" or "DapBreak"
			vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
		end

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Install golang specific config
		require("dap-go").setup({
			delve = {
				-- On Windows delve must be run attached or it crashes.
				-- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
				detached = vim.fn.has("win32") == 0,
			},
		})

		require("dap-vscode-js").setup({
			debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "node" },
		})

		for _, language in ipairs({ "typescript", "javascript" }) do
			require("dap").configurations[language] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = vim.fn.getcwd(),
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to process",
					processId = require("dap.utils").pick_process,
					cwd = vim.fn.getcwd(),
				},
			}
		end

		require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

		table.insert(require("dap").configurations.python, {
			type = "python",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			pythonPath = function()
				return "python"
			end,
		})

		local function start_compound(compound_name)
			local launch_json = vim.fn.getcwd() .. "/.vscode/launch.json"

			-- Check if the file exists
			if vim.fn.filereadable(launch_json) == 0 then
				vim.notify("Error: No .vscode/launch.json found!", vim.log.levels.ERROR)
				return
			end

			-- Attempt to read and parse JSON
			local ok, json = pcall(vim.fn.json_decode, vim.fn.readfile(launch_json))
			if not ok or not json then
				vim.notify("Error: Failed to parse launch.json!", vim.log.levels.ERROR)
				return
			end

			-- Ensure compounds exist
			if not json.compounds then
				vim.notify("Error: No 'compounds' found in launch.json!", vim.log.levels.ERROR)
				return
			end

			-- Find and start the selected compound
			for _, compound in ipairs(json.compounds) do
				if compound.name == compound_name then
					for _, config_name in ipairs(compound.configurations) do
						for _, config in ipairs(json.configurations or {}) do
							if config.name == config_name then
								if config.type == "node" then
									config.type = "pwa-node"
								end
								dap.run(config)
							end
						end
					end
					return
				end
			end

			-- If compound is not found
			vim.notify("Error: Compound '" .. compound_name .. "' not found!", vim.log.levels.ERROR)
		end

		_G.StopAllSessions = function()
			for _, session in pairs(dap.sessions()) do
				dap.terminate({ session = session })
			end

			vim.defer_fn(function()
				if vim.tbl_isempty(dap.sessions()) then
					dapui.close()
				end
			end, 100)
		end

		_G.SelectCompound = function()
			local launch_json = vim.fn.getcwd() .. "/.vscode/launch.json"

			-- Check if the file exists
			if vim.fn.filereadable(launch_json) == 0 then
				vim.notify("Error: No .vscode/launch.json found!", vim.log.levels.ERROR)
				return
			end

			-- Attempt to parse JSON
			local ok, json = pcall(vim.fn.json_decode, vim.fn.readfile(launch_json))
			if not ok or not json then
				vim.notify("Error: Failed to parse launch.json!", vim.log.levels.ERROR)
				return
			end

			-- Extract available compounds
			local compounds = {}
			if json.compounds then
				for _, compound in ipairs(json.compounds) do
					table.insert(compounds, compound.name)
				end
			end

			-- If no compounds are found
			if #compounds == 0 then
				vim.notify("Error: No debug compounds found in launch.json!", vim.log.levels.ERROR)
				return
			end

			-- Show a selection menu
			vim.ui.select(compounds, { prompt = "Select Debug Compound" }, function(choice)
				if choice then
					start_compound(choice)
				end
			end)
		end
		local current_session_index = 1

		_G.SwitchSession = function()
			local sessions = dap.sessions()
			if #sessions == 0 then
				print("No active debug sessions.")
				return
			end

			-- Switch to the next session
			current_session_index = current_session_index % #sessions + 1
			local current_session = sessions[current_session_index]

			-- Close dap-ui if it's already open
			dapui.close()

			-- Set the active session for dap-ui and open it
			dapui.open()

			dapui.toggle()

			-- Focus on the REPL for the current session
			dapui.eval("console.log('Switched to new session: " .. current_session.config.name .. "')")
		end

		-- Function to display active sessions in a select menu
		_G.ViewSessions = function()
			local sessions = dap.sessions()

			if #sessions == 0 then
				print("No active debug sessions.")
				return
			end

			-- Create a table with session names
			local session_names = {}
			for _, session in ipairs(sessions) do
				table.insert(session_names, session.config.name or "Unnamed Session")
			end

			-- Use vim.ui.select to show the list of active sessions
			vim.ui.select(session_names, {
				prompt = "Select a Debug Session:",
				format_item = function(item)
					return item
				end,
			}, function(choice)
				if choice then
					-- Find the selected session based on the name
					for _, session in ipairs(sessions) do
						if session.config.name == choice then
							print("Switching to session: " .. choice)

							-- Close dap-ui and reopen for the new session
							dapui.close()
							dapui.open()

							-- Set the active session
							dap.set_session(session)

							-- Focus the REPL of the selected session
							dap.repl.open()

							-- Optionally, show an optional message in the REPL (to indicate session switch)
							dapui.eval("console.log('Switched to session: " .. choice .. "')")

							-- This step ensures that dap.repl correctly displays the REPL for the new session
							dap.repl.eval('console.log("REPL switched to session: ' .. choice .. '")')
						end
					end
				end
			end)
		end

		-- Keybinding to open the session selector
		vim.api.nvim_set_keymap("n", "<leader>dv", ":lua ViewSessions()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>dc", ":lua SelectCompound()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>ds", ":lua SwitchSession()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>dq", ":lua StopAllSessions()<CR>", { noremap = true, silent = true })
	end,
}
