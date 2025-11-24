return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "s1n7ax/nvim-window-picker", -- 👈 required for the floating window picker
  },
  config = function()
    local picker = require("window-picker")

-- configure nvim-window-picker
picker.setup({
  autoselect_one = true,
  include_current_win = false,
  hint = "floating-big-letter",   -- <-- configure picker here
  selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  filter_rules = {
    bo = { filetype = { "NvimTree", "notify" }, buftype = { "terminal", "nofile" } },
  },
})

    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 50,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
      actions = {
        open_file = {
          quit_on_open = true,
          window_picker = {
            enable = true,
            picker = picker.pick_window,
          },
        },
      },
    })
  end,
}

