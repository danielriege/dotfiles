return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
    end,
  },

  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
    },
  },
  {
    "jecaro/fugitive-difftool.nvim",
    config = function()
      vim.api.nvim_create_user_command('Gcfir', require('fugitive-difftool').git_cfir, {})
      -- To the last
      vim.api.nvim_create_user_command('Gcla', require('fugitive-difftool').git_cla, {})
      -- To the next
      vim.api.nvim_create_user_command('Gcn', require('fugitive-difftool').git_cn, {})
      -- To the previous
      vim.api.nvim_create_user_command('Gcp', require('fugitive-difftool').git_cp, {})
      -- To the currently selected
      vim.api.nvim_create_user_command('Gcc', require('fugitive-difftool').git_cc, {})

    end,
  }
}
