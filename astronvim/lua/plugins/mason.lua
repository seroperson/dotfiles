-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",

        -- install any other package
        "marksman",
        "stylua",
        "prettier",

        -- somewhy doesn't included in astrocommunity.pack.nix
        "nixpkgs-fmt",
      },
    },
  },
}
