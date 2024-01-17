return {
  -- Configure AstroNvim updates
  updater = {
    -- remote to use
    remote = "origin",
    -- "stable" or "nightly"
    channel = "stable",
    -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    version = "latest",
    -- branch name (NIGHTLY ONLY)
    branch = "nightly",
    -- commit hash (NIGHTLY ONLY)
    commit = nil,
    -- nil, true, false (nil will pin plugins on stable only)
    pin_plugins = nil,
    -- skip prompts about breaking changes
    skip_prompts = false,
    -- show the changelog after performing an update
    show_changelog = true,
    -- automatically quit the current session after a successful update
    auto_quit = true,
    -- easily add new remotes to track
    remotes = {
      --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
      --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
      --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    },
  },

  -- Set colorscheme to use
  colorscheme = "catppuccin-mocha",

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        -- enable or disable format on save globally
        enabled = false,
      },
      -- disable formatting capabilities for the listed language servers
      disabled = {
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      -- default format timeout
      timeout_ms = 1000,
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },

  plugins = {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.colorscheme.catppuccin" },
    { import = "astrocommunity.editing-support.auto-save-nvim" },
    { import = "astrocommunity.programming-language-support.csv-vim" },
    { import = "astrocommunity.pack.ruby" },
    {
      "pocco81/auto-save.nvim",
      opts = {
        execution_message = {
          message = "Saved",
          cleaning_interval = 500
        }
      }
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
            hide_hidden = false
          }
        }
      }
    },
    {
      "ntpeters/vim-better-whitespace",
      lazy = false,
      init = function()
        vim.g.strip_whitespace_confirm = 0
        vim.g.strip_whitespace_on_save = 1
      end
    }
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }
  end,
}
