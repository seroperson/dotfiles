-- Mapping data with "desc" stored directly by vim.keymap.set().

return {
  -- first key is the mode
  n = {
    ["<C-n>"] = {
      function()
        require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1)
      end,
      desc = "Next buffer"
    },
    ["<C-p>"] = {
      function()
        require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1))
      end,
      desc = "Previous buffer"
    },
    ["<C-i>"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      desc = "Format"
    },
    ["<leader>lo"] = {
      require("telescope.builtin").lsp_implementations,
      desc = "Show implementations"
    },
    ["<C-o>"] = {
      require("telescope.builtin").lsp_implementations,
      desc = "Show implementations"
    },
    ["<leader>lq"] = {
      vim.lsp.buf.hover,
      desc = "Hover information"
    },
    ["<C-q>"] = {
      vim.lsp.buf.hover,
      desc = "Hover information"
    },
    ["<C-s>"] = {
      vim.lsp.buf.definition,
      desc = "Jump to definition"
    },
    ["<leader>lj"] = {
      vim.lsp.buf.definition,
      desc = "Jump to definition"
    },
    ["<leader>ls"] = {
      require("telescope.builtin").lsp_dynamic_workspace_symbols,
      desc = "Search workspace symbols"
    },
    -- comment current line
    -- same as default, but also moves cursor one line down
    ["<leader>/"] = {
      function()
        require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1)
        vim.cmd('norm! j')
      end,
      desc = "Toggle comment line",
    },
    ["<leader>ff"] = {
      function()
        require("telescope.builtin").git_files()
      end,
      desc = "Find all git files"
    },
    -- Disable 'Find all files'
    ["<leader>fF"] = false,
    -- Disable 'Find words in all files'
    ["<leader>fW"] = false,
    ["<leader>fw"] = {
      function()
        require("telescope.builtin").live_grep {
          additional_args = function(args) return vim.list_extend(args, { "--hidden", "--ignore", "--glob", "!**/.git/**" }) end,
        }
      end,
      desc = "Find words in all git files",
    },
    ["<leader>a"] = {
      -- todo: enable only when metals is active
      function()
        require("telescope").extensions.metals.commands()
      end,
      desc = "Metals actions"
    },
    Q = {
      ":q<cr>",
      desc = ":q"
    },
  },
  i = {
    -- stackoverflow.com/a/10757148
    ["<C-c>"] = "<ESC>",
  }
}
