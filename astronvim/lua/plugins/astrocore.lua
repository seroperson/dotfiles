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
      large_buf = { size = 1024 * 512, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        signcolumn = "auto", -- sets vim.opt.signcolumn
        spell = false, -- sets vim.opt.spell
        wrap = true, -- sets vim.opt.wrap
        showbreak = "↪ ",
        -- set Treesitter based folding
        -- foldexpr = "nvim_treesitter#foldexpr()",
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
        shortmess = vim.opt.shortmess:append "W",
        cmdheight = 1,
        messagesopt = "wait:0,history:1",
      },
      g = {
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
        --
        -- todo: probably everything here is outdated
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
        -- enable experimental resession.nvim session management
        resession_enabled = false,
        -- When a file is opened, Nvim searches all parent directories of that file for ".editorconfig" files,
        -- parses them, and applies any properties that match the opened file
        editorconfig = true,
      },
    },
    autocmds = {
      markdown_spell = {
        {
          event = { "FileType" },
          desc = "Enable spell checking for markdown files",
          pattern = { "markdown", "md" },
          callback = function()
            vim.opt_local.spell = true
            vim.opt_local.spelllang = "en_us,ru"
          end,
        },
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
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
          function() require("snacks.picker").lsp_implementations() end,
          desc = "Show implementations",
        },
        ["<C-O>"] = {
          function() require("snacks.picker").lsp_implementations() end,
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
        ["<Leader>lG"] = false,
        ["<Leader>ls"] = {
          function() require("snacks.picker").lsp_workspace_symbols() end,
          desc = "Search workspace symbols",
        },
        ["<Leader>ff"] = {
          function() require("snacks.picker").git_files() end,
          desc = "Find all git files",
        },
        -- Disable 'Find all files'
        ["<Leader>fF"] = false,
        -- Disable 'Find words in all files'
        ["<Leader>fW"] = false,
        ["<Leader>fw"] = {
          function() require("snacks.picker").grep() end,
          desc = "Find words in all git files",
        },
        Q = {
          "<cmd>q<cr>",
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
