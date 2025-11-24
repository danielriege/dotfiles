return {
  'VonHeikemen/fine-cmdline.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('fine-cmdline').setup({
      cmdline = {
        enable_keymaps = true,
        smart_history = true,
        prompt = ':'
      },
      popup = {
        position = {
          row = '30%',
          col = '50%',
        },
        size = {
          width = '30%',
        },
        border = {
          style = 'rounded',
          text = {
            top = " Command Line ",
            top_align = "center",
          },
        },
        win_options = {
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
        },
      },
      hooks = {
        before_mount = function(input)
          -- code
        end,
        after_mount = function(input)
          -- code
        end,
        set_keymaps = function(imap, feedkeys)
          -- code
        end
      }
    })
  end,
}
