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
      { "<leader>lr", ":LspRestart<CR>",                             desc = "Restart LSP",               mode = "n" },

      -- ollama
      { "<leader>]", group = "Ollama"},
      { "<leader>]c", ":Gen Chat<CR>", desc = "Chat", mode = "nv" },
      { "<leader>]a", ":Gen Ask<CR>", desc = "Ask", mode = "nv"},
    }

    which_key.add(mappings, opts)
  end,
})

local non_lsp_mappings = {
  -- Leader Mappings
  { "<leader>e",  "<cmd>NvimTreeFindFileToggle<CR>",                      desc = "Open file explorer",                   mode = "n" },
  { "<leader>p",  "\"_dP",                                                desc = "Paste without overwrite",              mode = "n" },
  { "<leader>/",  "<Plug>(comment_toggle_linewise_current)",              desc = "Toggle comment",                       mode = "n" },
  { "<leader>/", "<Plug>(comment_toggle_linewise_visual)",                desc = "Toggle comment (visual)",              mode = "v" },
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
  { ":",          "<cmd>FineCmdline<CR>",                                      desc = "Enhanced command line",                mode = "n" },
}

which_key.add(non_lsp_mappings)
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
  { "<leader>Hc", function() harpoon:list():clear() end,           desc = "Clear all Harpoon files", mode = "n" },
  { "<C-1>",     function() harpoon:list():select(1) end,         desc = "Open 1",            mode = "n" },
  { "<C-2>",     function() harpoon:list():select(2) end,         desc = "Open 2",            mode = "n" },
  { "<C-3>",     function() harpoon:list():select(3) end,         desc = "Open 3",            mode = "n" },
  { "<C-4>",     function() harpoon:list():select(4) end,         desc = "Open 4",            mode = "n" },
  { "<C-S-P>",   function() harpoon:list():next() end,            desc = "Next",              mode = "n" },
  { "<C-S-N>",   function() harpoon:list():prev() end,            desc = "Prev",              mode = "n" },
}

which_key.add(harpoon_mappings)


local git_diff_tool = {
  -- difftool
  { "t", group = "Diff Tool" },
  { "tn", ":Gcn<CR>", desc = "Jump to next entry", mode = "nv"},
  { "]q", ":Gcn<CR>", desc = "Jump to next entry", mode = "nv"},
  { "tp", ":Gcp<CR>", desc = "Jump to previous entry", mode = "nv"},
  { "[q", ":Gcp<CR>", desc = "Jump to previous entry", mode = "nv"},
  { "tf", ":Gcfir<CR>", desc = "Jump to first entry", mode = "nv"},
  { "tl", ":Gcla<CR>", desc = "Jump to last entry", mode = "nv"},
  { "tc", ":Gcc<CR>", desc = "Jump to current selected", mode = "nv"},
  { "tq", ":ccl<CR>", desc = "Close", mode = "nv"},
}

which_key.add(git_diff_tool)

-- Telescope Commands

local telescope_mappings = {
  { "<leader>ff", function() builtin.find_files() end,                                      desc = "Find files",     mode = "n" },
  { "<leader>fl", function() builtin.live_grep() end,                                       desc = "Live grep",      mode = "n" },
  { "<leader>fs", function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end, desc = "Grep string",    mode = "n" },
  -- Telescope Git Pickers
  { "<leader>fg", "<cmd>Telescope git_status<CR>",      desc = "Telescope Git status", mode = "n" },
  { "<leader>fb", "<cmd>Telescope git_branches<CR>",    desc = "Telescope Git branches", mode = "n" },
  { "<leader>fc", "<cmd>Telescope git_commits<CR>",     desc = "Telescope Git commits", mode = "n" },

}

which_key.add(telescope_mappings)

-- Register the semicolon mapping separately as it doesn't use the leader prefix
which_key.add({
  { ";", function() builtin.buffers() end, desc = "Find buffers", mode = "n" }
})

local visual_mappings = {
  { "J", "<CMD>:m '>+1<CR>gv=gv<CR>", desc = "Move selection down", mode = "v" },
  { "K", "<CMD>:m '<-2<CR>gv=gv<CR>", desc = "Move selection up",   mode = "v" }
}

which_key.add(visual_mappings)

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local git_mappings = {
      -- Fugitive Git workflow
      { "<leader>gg", function() vim.cmd("vert Git") end, desc = "Git status", mode = "n" },
      { "<leader>gd", function() vim.cmd("Gvdiffsplit") end, desc = "Diff split", mode = "n" },
      { "<leader>gb", function() vim.cmd("Git blame") end, desc = "Blame current line", mode = "n" },
      { "<leader>grd",
        function()
          -- prompt user for branch name
          local branch = vim.fn.input("Diff with branch/commit: ")
          if branch ~= "" then
            -- call Fugitive's Gvdiff with the entered branch
            vim.cmd("Gvdiff " .. branch)
          end
        end,
        desc = "Diff with branch (type name)",
        mode = "n"
      },

      { "<leader>gl", function() vim.cmd("vert Git log") end, desc = "Git Log", mode = "n" },
      { "<leader>ga", function() vim.cmd("Gwrite") end, desc = "Stage/Add current file", mode = "n" },
      { "<leader>gc", function() vim.cmd("Git commit") end, desc = "Git commit", mode = "n" },

      -- Gitsigns Hunk actions
      { "<leader>gs", function() gs.stage_hunk() end,      desc = "Stage hunk", mode = "n" },
      { "<leader>gu", function() gs.undo_stage_hunk() end, desc = "Unstage hunk", mode = "n" },
      { "<leader>gr", function() gs.reset_hunk() end,      desc = "Reset hunk", mode = "n" },
      { "<leader>gp", function() gs.preview_hunk() end,    desc = "Preview hunk", mode = "n" },

      -- Hunk navigation with diff fallback
      { "]c", function()
          if vim.wo.diff then
            vim.cmd("normal! ]c")
          else
            gs.next_hunk()
          end
        end, desc = "Next hunk", mode = "n" },
      { "[c", function()
          if vim.wo.diff then
            vim.cmd("normal! [c")
          else
            gs.prev_hunk()
          end
        end, desc = "Previous hunk", mode = "n" },

      -- Merge conflict resolution
      { "ghl", function() vim.cmd("diffget //2") end, desc = "Take from left (ours)", mode = "n" },
      { "ghr", function() vim.cmd("diffget //3") end, desc = "Take from right (theirs)", mode = "n" },
    }

    -- Use your which_key.add syntax
    which_key.add(git_mappings, { buffer = bufnr })
  end
})


--- Don't overwrite pastes in visual mode
-- vim.keymap.set("x", "<leader>p", "\"_dP")


-- Format command
-- vim.keymap.set("n", "<leader>f", function()
-- vim.lsp.buf.format()
-- end)

-- insert commands
vim.keymap.set('i', '<Right>', '<Right>', { noremap = true }) -- Make the right arrow behave normally in insert mode
vim.keymap.set('n', '<C-W>', '<C-w>', { noremap = true })
