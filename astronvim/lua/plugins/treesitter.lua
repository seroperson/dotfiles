-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
    },
    ensure_installed = {
      "lua",
      "vim",
      "markdown",
      "markdown_inline",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
