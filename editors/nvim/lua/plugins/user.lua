-- if true then return {} end-- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize dashboard options

{
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = (function()
          local cwd = vim.fn.getcwd()
          local home = vim.fn.expand("~")

          local name = (cwd == home)
            and "~"
            or vim.fn.fnamemodify(cwd, ":t")

          local default_header = table.concat({
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
 
          }, "\n")

          if vim.fn.executable("figlet") ~= 1 then
            return default_header
          end

          -- Try bigmono9 first, fallback to slant
          local function try_figlet(font)
            return vim.fn.systemlist({
              "figlet",
              "-f", font,
              name,
            })
          end
          
          local output = try_figlet("bigmono9")
          
          if vim.v.shell_error ~= 0 or not output or vim.tbl_isempty(output) then
            output = try_figlet("slant")
          end

          if vim.v.shell_error ~= 0 or not output or vim.tbl_isempty(output) then
            return default_header
          end

          return table.concat(output, "\n")
        end)(),
      },
    },
  },
},

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  }, -- fzf-lua configuration
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("fzf-lua").setup {} end,
  },

  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = function(_, opts)
      local maps = opts.mappings or {n = {}}
      
      local has_fzf, fzf = pcall(require, "fzf-lua")
      
      if has_fzf then
        -- Override Snacks mappings with fzf-lua
        maps.n["<leader>fw"] = { function() fzf.live_grep() end, desc = "Find words (fzf-lua)" }
        maps.n["<leader>ff"] = { function() fzf.files() end, desc = "Find files (fzf-lua)" }
        maps.n["<leader>fb"] = { function() fzf.buffers() end, desc = "Find buffers (fzf-lua)" }
        maps.n["<leader>fo"] = { function() fzf.oldfiles() end, desc = "Find old files (fzf-lua)" }
        maps.n["<leader>fc"] = { function() fzf.grep_cword() end, desc = "Find word under cursor (fzf-lua)" }
        --maps.n["<leader>fl"] = { function() fzf.lines() end, desc = "Find lines (fzf-lua)" }
      end
      
      
      return opts
    end,
  },

}
