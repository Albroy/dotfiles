---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = {
      filetypes = {
        extension = {
          twig = "twig",
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "twig" })
    end,
  },
}
