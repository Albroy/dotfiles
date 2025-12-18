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
        maps.n["<leader>fl"] = { function() fzf.lines() end, desc = "Find lines (fzf-lua)" }
      end
      
      -- Mapping to extract IPv4 addresses from current file
      maps.n["<leader>ip"] = {
        function()
          local content = vim.fn.getline(0, '$')
          local ips = {}
          
          -- IPv4 regex pattern
          local ip_pattern = '(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)'
          
          for line in ipairs(content) do
            for ip in string.gmatch(content[line], ip_pattern) do
              table.insert(ips, ip)
            end
          end
          
          if #ips > 0 then
            local seen = {}
            local unique_ips = {}
            for _, ip in ipairs(ips) do
              if not seen[ip] then
                seen[ip] = true
                table.insert(unique_ips, ip)
              end
            end
            
            local ip_text = table.concat(unique_ips, '\n')
            vim.fn.setreg('ip', ip_text)  -- Store in register 'ip'
            vim.cmd('let @0 = "' .. ip_text:gsub('\n', '\\n') .. '"')
            vim.cmd('let @" = "' .. ip_text:gsub('\n', '\\n') .. '"')
            print(string.format("Found %d unique IPv4 addresses (stored in register 'ip', use p to paste)", #unique_ips))
          else
            print("No IPv4 addresses found")
          end
        end,
        desc = "Extract IPv4 addresses from current file"
      }
      
      -- Mapping to convert IPs from register to /32 CIDR
      maps.n["<leader>i3"] = {
        function()
          -- Read from register 'ip' (output from <leader>ip)
          local ip_text = vim.fn.getreg('ip')
          if ip_text == '' then
            print("Register 'ip' is empty. Use <leader>ip first to extract IPs.")
            return
          end
          
          local content = vim.fn.getline(0, '$')
          local existing_cidr_ips = {}
          local cidr_pattern = '(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)/%d+'
          
          for line in ipairs(content) do
            for ip in string.gmatch(content[line], cidr_pattern) do
              existing_cidr_ips[ip] = true
            end
          end
          
          local ips = {}
          for ip in ip_text:gmatch('(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)') do
            if not existing_cidr_ips[ip] then
              table.insert(ips, ip)
            end
          end
          print("Debug: Found " .. #ips .. " IPs after filtering")
          
          if #ips > 0 then
            local seen = {}
            local unique_ips = {}
            for _, ip in ipairs(ips) do
              if not seen[ip] then
                seen[ip] = true
                table.insert(unique_ips, ip)
              end
            end
            
            -- Convert to /32 CIDR and insert directly in current file
            local cidr_text = table.concat(unique_ips, '\n'):gsub('(%d+%.%d+%.%d+%.%d+)', '%1/32')
            vim.fn.setreg('ip_cidr', cidr_text)  -- Also store for reference
            vim.api.nvim_put(vim.split(cidr_text, '\n'), 'l', true, true)
            print(string.format("Inserted %d new IPs as /32 CIDR", #unique_ips))
          else
            print("No new IPs to convert (all already exist as CIDR)")
          end
        end,
        desc = "Convert IPs from register 'ip' to /32 CIDR (only new ones not in file)"
      }
      
      
      return opts
    end,
  },

}
