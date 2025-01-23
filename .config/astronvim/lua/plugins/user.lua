-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    -- https://github.com/numToStr/Comment.nvim
    "numToStr/Comment.nvim",
    opts = {
      toggler = {
        -- Line-comment toggle keymap
        line = "<Leader>/",
      },
    },
  },

  -- Always save automatically
  {
    "okuuva/auto-save.nvim",
    opts = {
      -- delay after which a pending save is executed
      debounce_delay = 3000,
      -- don't trigger autoformat
      noautocmd = true,
    },
  },

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
          hide_hidden = false,
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 1,
        },
        container = {
          enable_character_fade = false,
        },
      },
      window = {
        width = 30,
      },
    },
  },

  -- Always trim trailing whitespaces
  {
    "ntpeters/vim-better-whitespace",
    config = function()
      vim.g.strip_whitespace_confirm = 0
      vim.g.strip_whitespace_on_save = 1
    end,
  },

  -- override nvim-cmp plugin
  -- https://docs.astronvim.com/recipes/cmp/
  {
    "hrsh7th/nvim-cmp",
    -- override the options table that is used in the `require("cmp").setup()` call
    opts = function(_, opts)
      -- opts parameter is the default options table
      -- the function is lazy loaded so cmp is able to be required
      local cmp = require "cmp"
      -- modify the sources part of the options table
      opts.sources = cmp.config.sources {
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }
    end,
  },

  {
    "jackMort/ChatGPT.nvim",
    -- GigaChat tweaks :clown:
    opts = function(_, opts)
      opts.extra_curl_params = {
        "--insecure",
      }
      opts.openai_params = {
        model = "GigaChat",
      }
      opts.actions_paths = {
        vim.fn.stdpath "config" .. "/gpt-actions.json",
      }
    end,
  },
}
