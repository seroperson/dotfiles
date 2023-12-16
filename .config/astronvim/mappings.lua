-- Mapping data with "desc" stored directly by vim.keymap.set().

return {
  -- first key is the mode
  n = {
    ["<C-s>"] = { 
      ":w!<cr>", 
      desc = "Save File" 
    },
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
      -- stackoverflow.com/questions/506075/how-do-i-fix-the-indentation-of-an-entire-file-in-vi#comment8742998_506079
      "gg=G''",
      desc = "Fix indentation and return" 
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
