return {
  "sonarlint.nvim",
  dir = "/home/riegedan/git/sonarlint.nvim/",
  dev = true,
  config = function()
    require('sonarlint').setup({
	server = {
		cmd = {
      'java',
      '-Djava.net.useSystemProxies=true',
      '-jar',
      '/home/riegedan/.vscode/extensions/sonarsource.sonarlint-vscode-4.12.0-linux-x64/server/sonarlint-ls.jar',
      '-stdio',
			'-analyzers',
			-- paths to the analyzers you need, using those for python and java in this example
			vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
			vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
			vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
		},
		settings = {
			sonarlint = {
				pathToCompileCommands = vim.fn.expand("$PWD/build/sonarlint_compile_commands.json"),

--				connectedMode = {
--					connections = {
--            sonarqube = {{
--              serverUrl = "https://sonarqube.drager.net",
--						  connectionId = "https-sonarqube-draeger-net-",
--            }}
--          },
--          project = {
--            connectionId = "https-sonarqube-draeger-net-",
--            projectKey = "txng"
--          }
--
--				},
				disableTelemetry = true,
				focusOnNewCode = true,
			},
			files = {
				exclude = {
					["**/.git"] = true
				}
			}
		}

	},
	filetypes = {
		-- Tested and working
		'python',
		'cpp',
		'java',
	}
})
  end,
}
