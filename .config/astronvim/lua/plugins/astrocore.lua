-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = {
        -- sets vim.opt.relativenumber
        relativenumber = true,
        -- sets vim.opt.number
        number = true,
        -- sets vim.opt.spell
        spell = true,
        spelllang = "en_us",
        -- sets vim.opt.signcolumn to auto
        signcolumn = "auto",
        -- sets vim.opt.wrap
        wrap = true,
        showbreak = "↪ ",
        -- set Treesitter based folding
        foldexpr = "nvim_treesitter#foldexpr()",
        foldmethod = "expr",
        -- linebreak soft wrap at words
        linebreak = true,
        -- show whitespace characters
        list = true,
        -- don't redraw immediately (helps with macros)
        lazyredraw = true,
        -- enable mouse, sometimes it's just more comfortable
        mouse = "a",
        -- some additional metals config
        completeopt = { "menuone", "noinsert", "noselect" },
      },
      g = {
        -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
        autoformat_enabled = true,
        -- enable completion at start
        cmp_enabled = true,
        -- enable autopairs at start
        autopairs_enabled = true,
        -- set the visibility of diagnostics in the UI (0=off, 1=only show in status line, 2=virtual text off, 3=all on)
        diagnostics_mode = 3,
        -- disable icons in the UI (disable if no nerd font is available, requires :PackerSync after changing)
        icons_enabled = true,
        -- disable notifications when toggling UI elements
        ui_notifications_enabled = true,
        -- enable experimental resession.nvim session management (will be default in AstroNvim v4)
        resession_enabled = false,
        -- When a file is opened, Nvim searches all parent directories of that file for ".editorconfig" files,
        -- parses them, and applies any properties that match the opened file
        editorconfig = true,
      },
    },
    -- Mappings can be configured through AstroCore as well.
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
        ["<C-N>"] = {
          function() require("astrocore.buffer").nav(vim.v.count1) end,
          desc = "Next buffer",
        },
        ["<C-P>"] = {
          function() require("astrocore.buffer").nav(-vim.v.count1) end,
          desc = "Previous buffer",
        },
        ["<C-I>"] = {
          function() vim.lsp.buf.format { async = true } end,
          desc = "Format",
        },
        ["<Leader>lo"] = {
          function() require("telescope.builtin").lsp_implementations() end,
          desc = "Show implementations",
        },
        ["<C-O>"] = {
          function() require("telescope.builtin").lsp_implementations() end,
          desc = "Show implementations",
        },
        ["<Leader>lq"] = {
          function() vim.lsp.buf.hover() end,
          desc = "Hover information",
        },
        ["<C-Q>"] = {
          function() vim.lsp.buf.hover() end,
          desc = "Hover information",
        },
        ["<C-S>"] = {
          function() vim.lsp.buf.definition() end,
          desc = "Jump to definition",
        },
        ["<Leader>lj"] = {
          function() vim.lsp.buf.definition() end,
          desc = "Jump to definition",
        },
        ["<Leader>ls"] = {
          function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,
          desc = "Search workspace symbols",
        },
        ["<Leader>ff"] = {
          function() require("telescope.builtin").git_files() end,
          desc = "Find all git files",
        },
        -- Disable 'Find all files'
        ["<Leader>fF"] = false,
        -- Disable 'Find words in all files'
        ["<Leader>fW"] = false,
        ["<Leader>fw"] = {
          function()
            require("telescope.builtin").live_grep {
              additional_args = function(args)
                return vim.list_extend(args, { "--hidden", "--ignore", "--glob", "!**/.git/**" })
              end,
            }
          end,
          desc = "Find words in all git files",
        },
        ["<Leader>a"] = {
          -- todo: enable only when metals is active
          function() require("telescope").extensions.metals.commands() end,
          desc = "Metals actions",
        },
        Q = {
          ":q<cr>",
          desc = ":q",
        },
      },
      i = {
        -- stackoverflow.com/a/10757148
        ["<C-C>"] = "<ESC>",
      },
    },
  },
}
