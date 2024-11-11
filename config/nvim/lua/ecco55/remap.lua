local which_key = require "which-key"
local builtin = require('telescope.builtin')
local harpoon = require('harpoon')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }

    local mappings = {
      -- LSP and Diagnostic Mappings
      { "gR",         "<cmd>Telescope lsp_references<CR>",           desc = "Show LSP references",       mode = "n" },
      { "gD",         function() vim.lsp.buf.declaration() end,      desc = "Go to declaration",         mode = "n" },
      { "gd",         "<cmd>Telescope lsp_definitions<CR>",          desc = "Show LSP definitions",      mode = "n" },
      { "gi",         "<cmd>Telescope lsp_implementations<CR>",      desc = "Show LSP implementations",  mode = "n" },
      { "gb",         "<cmd>Telescope diagnostics bufnr=0<CR>",      desc = "Show buffer diagnostics",   mode = "n" },
      { "gl",         function() vim.diagnostic.open_float() end,    desc = "Show line diagnostics",     mode = "n" },
      { "K",          function() vim.lsp.buf.hover() end,            desc = "Show hover information",    mode = "n" },
      { "]d",         function() vim.diagnostic.goto_next() end,     desc = "Go to next diagnostic",     mode = "n" },
      { "[d",         function() vim.diagnostic.goto_prev() end,     desc = "Go to previous diagnostic", mode = "n" },

      -- Leader Key Mappings
      { "<leader>l",  group = "LSP" },
      { "<leader>la", function() vim.lsp.buf.code_action() end,      desc = "Code action",               mode = "n" },
      { "<leader>ln", function() vim.lsp.buf.rename() end,           desc = "Rename",                    mode = "n" },
      { "<leader>lw", function() vim.lsp.buf.workspace_symbol() end, desc = "Workspace symbol",          mode = "n" },
      { "<leader>lr", ":LspRestart<CR>",                             desc = "Restart LSP",               mode = "n" }
    }

    which_key.add(mappings, opts)

    -- vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
    -- vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
    -- vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
    -- vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
    -- vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
    -- vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
    -- vim.keymap.set('n', '<leader>lca', function() vim.lsp.buf.code_action() end, opts)
    -- vim.keymap.set('n', '<leader>lrr', function() vim.lsp.buf.references() end, opts)
    -- vim.keymap.set('n', '<leader>lrn', function() vim.lsp.buf.rename() end, opts)
    -- vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)

    -- https://www.mitchellhanberg.com/modern-format-on-save-in-neovim/
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = event.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = event.data.client_id }
      end

    })
  end,
})

local non_lsp_mappings = {
  -- Leader Mappings
  { "<leader>e",  "<cmd>NvimTreeFindFileToggle<CR>",                      desc = "Open file explorer",                   mode = "n" },
  { "<leader>p",  "\"_dP",                                                desc = "Paste without overwrite",              mode = "n" },
  { "<leader>/",  "<Plug>(comment_toggle_linewise_current)",              desc = "Toggle comment",                       mode = "n" },
  { "<leader>s",  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Search and replace word under cursor", mode = "n" },
  -- Uncomment this if needed
  -- { "<leader>t", "<cmd>Today<cr>", desc = "Open today's note", mode = "n" },

  -- Non-leader Mappings
  { "J",          "mzJ`z",                                                desc = "Join lines and keep cursor position",  mode = "n" },
  { "<C-d>",      "<C-d>zz",                                              desc = "Half page down and center",            mode = "n" },
  { "<C-u>",      "<C-u>zz",                                              desc = "Half page up and center",              mode = "n" },
  { "n",          "nzzzv",                                                desc = "Next search result and center",        mode = "n" },
  { "N",          "Nzzzv",                                                desc = "Previous search result and center",    mode = "n" },
  { "Q",          "<nop>",                                                desc = "Disable Ex mode",                      mode = "n" },
  { "<leader>nh", ":nohl<CR>",                                            desc = "Clear search highlights",              mode = "n" },
}

which_key.add(non_lsp_mappings)

-- vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
-- vim.keymap.set("n", "J", "mzJ`z")       -- Keep cursor in same position on line join
-- vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Keep cursor in middle on half page jump down
-- vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Keep cursor in middle on half page jump down
-- vim.keymap.set("n", "n", "nzzzv")       -- Keep searched term in middle
-- vim.keymap.set("n", "N", "Nzzzv")       -- Keep reverse searched term in middle
-- vim.keymap.set("n", "Q", "<nop>")       --- Just undo capital Q support
-- vim.keymap.set("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)")
-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- vim.keymap.set("n", "<leader>t", ":Today<CR>")



-- Harpoon commands

local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require("telescope.pickers").new({}, {
    prompt_title = "Harpoon",
    finder = require("telescope.finders").new_table({
      results = file_paths,
    }),
    previewer = conf.file_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end

local harpoon_mappings = {
  { "<leader>a", function() harpoon:list():add() end,             desc = "Add to Harpoon",    mode = "n" },
  { "<leader>h", function() toggle_telescope(harpoon:list()) end, desc = "Show Harpoon Menu", mode = "n" },
  { "<C-h>",     function() harpoon:list():select(1) end,         desc = "Open 1",            mode = "n" },
  { "<C-t>",     function() harpoon:list():select(2) end,         desc = "Open 2",            mode = "n" },
  { "<C-n>",     function() harpoon:list():select(3) end,         desc = "Open 3",            mode = "n" },
  { "<C-s>",     function() harpoon:list():select(4) end,         desc = "Open 4",            mode = "n" },
  { "<C-S-P>",   function() harpoon:list():next() end,            desc = "Next",              mode = "n" },
  { "<C-S-N>",   function() harpoon:list():prev() end,            desc = "Prev",              mode = "n" },
}

which_key.add(harpoon_mappings)

-- Telescope Commands

local telescope_mappings = {
  { "<leader>ff", function() builtin.find_files() end,                                      desc = "Find files",     mode = "n" },
  { "<leader>fg", function() builtin.git_files() end,                                       desc = "Find git files", mode = "n" },
  { "<leader>fl", function() builtin.live_grep() end,                                       desc = "Live grep",      mode = "n" },
  { "<leader>fs", function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Grep string",    mode = "n" }
}

which_key.add(telescope_mappings)

-- Register the semicolon mapping separately as it doesn't use the leader prefix
which_key.add({
  { ";", function() builtin.buffers() end, desc = "Find buffers", mode = "n" }
})

-- vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
-- vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
-- vim.keymap.set('n', '<leader>fl', builtin.live_grep, {})
-- vim.keymap.set('n', ';', builtin.buffers, {})



-- Use move command while highlighted to move text
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- vim.keymap.set("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)")

local visual_mappings = {
  { "J", "<CMD>:m '>+1<CR>gv=gv<CR>", desc = "Move selection down", mode = "v" },
  { "K", "<CMD>:m '<-2<CR>gv=gv<CR>", desc = "Move selection up",   mode = "v" }
}

which_key.add(visual_mappings)

--- Don't overwrite pastes in visual mode
-- vim.keymap.set("x", "<leader>p", "\"_dP")


-- Format command
-- vim.keymap.set("n", "<leader>f", function()
-- vim.lsp.buf.format()
-- end)

-- insert commands
vim.keymap.set('i', '<Right>', '<Right>', { noremap = true }) -- Make the right arrow behave normally in insert mode
vim.keymap.set('n', '<C-W>', '<C-w>', { noremap = true })
