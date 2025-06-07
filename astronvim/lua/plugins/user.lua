-- You can also add or configure plugins by creating files in this `plugins/` folder

---@type LazySpec
return {

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            " █████  ███████ ████████ ██████   ██████ ",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████ ",
            "",
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
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
      -- disable save notifications
      trigger_events = { "InsertLeave", "TextChanged" },
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
          return true
        end
        return false
      end,
      write_all_buffers = false,
      debounce_delay = 3000,
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
      vim.g.strip_only_modified_lines = 1
      -- disable whitespace strip messages
      vim.g.better_whitespace_verbosity = 0
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened",
        callback = function() vim.cmd [[DisableWhitespace]] end,
      })
    end,
  },

  -- lua spellfile.vim port
  { "cuducos/spellfile.nvim" },
}
