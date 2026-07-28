return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- classic branch: keeps configs.setup API; `main` is the 0.11+ rewrite with a different API
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript"
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}