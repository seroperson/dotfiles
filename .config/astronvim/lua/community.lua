-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.editing-support.auto-save-nvim" },
  -- { import = "astrocommunity.programming-language-support.csv-vim" },
  -- { import = "astrocommunity.pack.ruby" },
  { import = "astrocommunity.pack.scala" },
  { import = "astrocommunity.pack.lua" }
}
