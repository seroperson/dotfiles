-- set vim options here (vim.<first_key>.<second_key> = value)
return {
  opt = {
    -- sets vim.opt.relativenumber
    relativenumber = true,
    -- sets vim.opt.number
    number = true,
    -- sets vim.opt.spell
    spell = false,
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
    -- disable mouse
    mouse = ""
  },
  g = {
    -- sets vim.g.mapleader
    mapleader = " ",
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
  },
}
-- If you need more control, you can use the function()...end notation
-- return function(local_vim)
--   local_vim.opt.relativenumber = true
--   local_vim.g.mapleader = " "
--   local_vim.opt.whichwrap = vim.opt.whichwrap - { 'b', 's' } -- removing option from list
--   local_vim.opt.shortmess = vim.opt.shortmess + { I = true } -- add to option list
--
--   return local_vim
-- end