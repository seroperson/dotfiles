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
      debounce_delay = 500,
    },
  },

  {
    "johmsalas/text-case.nvim",
    opts = {},
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

  {
    "rcarriga/nvim-dap-ui",
    config = function(plugin, opts)
      -- run default AstroNvim nvim-dap-ui configuration function
      require "astronvim.plugins.configs.nvim-dap-ui"(plugin, opts)

      -- disable dap events that are created
      local dap = require "dap"
      dap.listeners.after.event_initialized.dapui_config = nil
      dap.listeners.before.event_terminated.dapui_config = nil
      dap.listeners.before.event_exited.dapui_config = nil
    end,
  },

  {
    "stevanmilic/neotest-scala",
    opts = function(_, opts)
      opts.args = { "-v" }
      opts.runner = "bloop"
    end,
  },

  {
    "nvim-neotest/neotest",
    dependencies = { "stevanmilic/neotest-scala", config = function() end },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-scala"(require("astrocore").plugin_opts "neotest-scala"))
    end,
  },

  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = {
        default = { "lsp" },
      }
    end,
  },
}
