-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    -- https://github.com/numToStr/Comment.nvim?tab=readme-ov-file#configuration-optional
    "numToStr/Comment.nvim",
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = '<Leader>/'
      }
    }
  },

  -- Always save automatically
  -- {
  --   "Pocco81/auto-save.nvim",
  --   opts = {
  --     execution_message = {
  --       message = "Saved",
  --       cleaning_interval = 500
  --     }
  --   }
  -- },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- by default there are 'buffers' also
      sources = { "filesystem", "git_status" },
      filesystem = {
        filtered_items = {
          -- dotfiles are hidden by default
          hide_dotfiles = false,
          -- works only in Windows, but still
          hide_hidden = false
        }
      }
    }
  },

  -- Always trim trailing whitespaces
  {
    "ntpeters/vim-better-whitespace",
    config = function()
      vim.g.strip_whitespace_confirm = 0
      vim.g.strip_whitespace_on_save = 1
    end
  }
}
