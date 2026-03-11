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

  -- Git mappings (always available)
  { "<leader>gg", function()
      vim.cmd("vert Git")
      -- Auto-close the Git status window when opening a file from it
      local git_buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_create_autocmd("BufLeave", {
        buffer = git_buf,
        callback = function()
          -- Delay slightly to check what buffer we entered
          vim.defer_fn(function()
            local new_buf = vim.api.nvim_get_current_buf()
            local buftype = vim.api.nvim_get_option_value('buftype', { buf = new_buf })
            -- Only close if we're entering a normal file buffer (empty buftype)
            -- This excludes command line, quickfix, terminal, etc.
            if buftype == '' and new_buf ~= git_buf then
              -- Find and close the window containing the git status buffer
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == git_buf then
                  vim.api.nvim_win_close(win, false)
                  -- Remove this autocmd after closing
                  vim.api.nvim_clear_autocmds({ buffer = git_buf, event = "BufLeave" })
                  break
                end
              end
            end
          end, 50)
        end,
      })
    end, desc = "Git status", mode = "n" },
  { "<leader>gm", function()
      vim.cmd("Gvdiffsplit!")
      -- After opening the 3-way diff, set titles for each window using winbar
      vim.defer_fn(function()
        local wins = vim.api.nvim_tabpage_list_wins(0)
        -- Get windows from left to right based on their column position
        local win_positions = {}
        for _, win in ipairs(wins) do
          if vim.wo[win].diff then
            local buf = vim.api.nvim_win_get_buf(win)
            local bufname = vim.api.nvim_buf_get_name(buf)
            local pos = vim.api.nvim_win_get_position(win)
            table.insert(win_positions, { win = win, col = pos[2], name = bufname })
          end
        end

        -- Sort windows by column position (left to right)
        table.sort(win_positions, function(a, b) return a.col < b.col end)

        -- Check buffer names to identify which is which
        -- fugitive:// buffers: :2: = OURS (HEAD), :3: = THEIRS (MERGE_HEAD)
        -- working file has no fugitive:// prefix and contains conflict markers
        if #win_positions == 3 then
          for i, wp in ipairs(win_positions) do
            local label = ""
            if wp.name:match("fugitive://") then
              -- :2: is stage 2 = OURS (HEAD/current branch)
              if wp.name:match(":2:") or wp.name:match("//2/") then
                label = "%#DiffDelete#  OURS (HEAD/current branch) - use ghl  %*"
              -- :3: is stage 3 = THEIRS (MERGE_HEAD/incoming branch)
              elseif wp.name:match(":3:") or wp.name:match("//3/") then
                label = "%#DiffAdd#  THEIRS (incoming branch) - use ghr  %*"
              else
                label = "%#WarningMsg# Unknown fugitive buffer " .. i .. " %*"
              end
            else
              -- This is the working copy with conflict markers - this is what you edit
              label = "%#DiffChange#  WORKING COPY (has conflict markers) - EDIT HERE  %*"
            end

            vim.api.nvim_win_call(wp.win, function()
              vim.wo.winbar = label
            end)
          end
        end
      end, 100)
    end, desc = "Open 3-way merge conflict view", mode = "n" },

  -- Jump to conflict markers
  { "]x", function()
      vim.fn.search("^\\(<<<<<<<\\|=======\\|>>>>>>>\\)", "W")
    end, desc = "Next conflict marker", mode = "n" },
  { "[x", function()
      vim.fn.search("^\\(<<<<<<<\\|=======\\|>>>>>>>\\)", "bW")
    end, desc = "Previous conflict marker", mode = "n" },

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
  { "<leader>fd",
    function()
      -- Prompt for branch to compare against
      local branch = vim.fn.input("Show files changed vs branch: ")
      if branch ~= "" then
        -- Auto-prepend origin/ if not already specified
        if not branch:match("^origin/") and not branch:match("^refs/") then
          branch = "origin/" .. branch
        end

        -- Get the list of changed files between target branch and current branch
        -- branch...HEAD shows what changed on current branch since diverging from branch
        local handle = io.popen("git diff --name-only " .. vim.fn.shellescape(branch) .. "...HEAD")
        if handle then
          local result = handle:read("*a")
          handle:close()

          -- Split result into table of file paths
          local files = {}
          for file in result:gmatch("[^\r\n]+") do
            table.insert(files, file)
          end

          if #files > 0 then
            -- Create telescope picker with the changed files
            require("telescope.pickers").new({}, {
              prompt_title = "Files Changed vs " .. branch,
              finder = require("telescope.finders").new_table({
                results = files,
              }),
              previewer = conf.file_previewer({}),
              sorter = conf.generic_sorter({}),
            }):find()
          else
            print("No files changed between current branch and " .. branch)
          end
        end
      end
    end,
    desc = "Files changed vs branch",
    mode = "n"
  },

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
      { "<leader>gd",
        function()
          -- Prompt user for branch name to compare against
          local branch = vim.fn.input("Diff current file with branch: ")
          if branch ~= "" then
            -- Use Gvdiffsplit! for 3-way diff (includes merge base)
            -- This shows: [target branch] [merge base] [current branch]
            vim.cmd("Gvdiffsplit! " .. vim.fn.fnameescape(branch))
          end
        end,
        desc = "3-way diff with branch",
        mode = "n"
      },
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
      { "<leader>gP", function() vim.cmd("Git push") end, desc = "Git push", mode = "n" },

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
