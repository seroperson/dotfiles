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

  {
    "ravitemer/mcphub.nvim",
    -- uncomment the following line to load hub lazily
    --cmd = "MCPHub",  -- lazy load
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    build = "bundled_build.lua", -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    config = function()
      require("mcphub").setup {
        use_bundled_binary = true,
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          },
        },
      }
    end,
  },
}
