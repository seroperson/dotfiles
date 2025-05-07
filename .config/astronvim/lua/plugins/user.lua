-- You can also add or configure plugins by creating files in this `plugins/` folder
--
local x = {
  "olimorris/codecompanion.nvim",
  config = function()
    require("codecompanion").setup {
      opts = {
        log_level = "DEBUG", -- or "TRACE"
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
      adapters = {
        opts = {
          show_defaults = false,
        },
        yandexgpt = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://localhost:4000",
              api_key = "fake",
            },
            schema = {
              model = {
                default = "yandexgpt",
              },
              temperature = {
                default = 0,
              },
            },
          })
        end,
        qwen3 = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "qwen3", -- Give this adapter a different name to differentiate it from the default ollama adapter
            env = {
              url = "http://172.27.16.1:11434",
            },
            schema = {
              model = {
                default = "qwen3:30b-a3b-fp16",
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "yandexgpt",
        },
        inline = {
          adapter = "yandexgpt",
        },
      },
    }
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
  },
}

local y = {
  "yetone/avante.nvim",
  lazy = false,

  -- dependencies = {
  -- {
  -- "AstroNvim/astrocore",
  -- opts = function(_, opts)
  -- opts.mappings.n = {
  -- ["<Leader>A"] = {
  -- desc = "avante: new chat",
  -- },
  -- }
  -- end,
  -- },
  -- },
  --
  opts = function(_, opts)
    local global_provider = "litellm-or"
    opts.provider = global_provider
    opts.auto_suggestions_provider = global_provider
    opts.memory_summary_provider = global_provider
    opts.cursor_applying_provider = global_provider
    --
    -- opts.ollama = {
    -- endpoint = "http://172.27.16.1:11434",
    -- api_key_name = nil,
    -- disable_tools = false,
    -- model = "qwen3:30b-a3b-fp16",
    -- }
    opts.vendors = {
      ["litellm-lm"] = {
        __inherited_from = "openai",
        -- endpoint = "http://localhost:4000",
        endpoint = "http://172.27.16.1:1234/v1",
        temperature = 0,
        api_key_name = nil,
        disable_tools = false,
        model = "qwen3-14b",
      },
      ["litellm-stable-code"] = {
        __inherited_from = "openai",
        endpoint = "http://localhost:4000",
        -- endpoint = "http://172.27.16.1:1234/v1",
        api_key_name = nil,
        disable_tools = false,
        model = "stable-code-instruct-3b",
      },
      ["litellm-yandexgpt"] = {
        __inherited_from = "openai",
        endpoint = "http://localhost:4000",
        -- endpoint = "http://172.27.16.1:1234/v1",
        temperature = 0,
        reasoning_effort = "medium",
        api_key_name = nil,
        disable_tools = false,
        model = "yandexgpt",
      },
      ["litellm-or"] = {
        __inherited_from = "openai",
        endpoint = "http://localhost:4000",
        temperature = 0,
        api_key_name = nil,
        disable_tools = false,
        model = "or-claude-3.7",
        -- model = "or-qwen3-235b",
      },
    }
    opts.suggestion = {
      debounce = 600,
      throttle = 600,
    }
    opts.behaviour = {
      auto_suggestions = false,
    }
    opts.system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub:get_active_servers_prompt()
    end
    -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
    opts.custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end
    opts.disabled_tools = {
      "list_files",
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash",
    }

    -- provider = "ollama",
    -- auto_suggestions_provider = "ollama",
    -- memory_summary_provider = "ollama",
    -- ollama = {
    -- endpoint = "http://localhost:11434",
    -- model = "phi4",
    -- },
    --
    -- provider = "openai",
    -- auto_suggestions_provider = "openai",
    -- memory_summary_provider = "openai",
    -- openai = {
    -- endpoint = "http://localhost:4000",
    -- model = "llama3.3",
    -- temperature = 0,
    -- max_tokens = 10240000,
    -- timeout = 1200000, -- Timeout in milliseconds, increase this for reasoning models
    -- max_completion_tokens = 16384, -- Increase this to include reasoning tokens (for reasoning models)
    -- reasoning_effort = "medium",
    -- },

    -- provider = "openai",
    -- auto_suggestions_provider = "openai",
    -- memory_summary_provider = "openai",
    -- openai = {
    -- endpoint = "http://localhost:4000",
    -- model = "llama3.3",
    -- temperature = 0,
    -- max_tokens = 10240000,
    -- timeout = 1200000, -- Timeout in milliseconds, increase this for reasoning models
    -- max_completion_tokens = 16384, -- Increase this to include reasoning tokens (for reasoning models)
    -- reasoning_effort = "medium",
    -- },
  end,
}

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

  y,
}
