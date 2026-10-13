---@module 'lazy'

---@type LazySpec[]
return {
  -- jk = <Esc>
  {
    "kana/vim-arpeggio",
    event = "InsertEnter",
    init = function()
      vim.g.arpeggio_timeoutlen = 70
    end,
    config = function()
      vim.fn["arpeggio#map"]("i", "", 1, "jk", "<Esc>")
      -- Full-width jk during IME
      vim.fn["arpeggio#map"]("i", "", 1, "ｊｋ", "<Esc>")
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      fast_wrap = {},
      enable_check_bracket_line = true,
      -- no nvim-treesitter in this config
      check_ts = false,
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)

      -- rules

      local cond = require("nvim-autopairs.conds")

      -- don't expand single-quote in Rust
      ---@type table | nil
      local rust_single_quote_rules = vim
        .iter(npairs.get_rules("'"))
        :filter(function(rule)
          return #(rule.filetypes or {}) == 1 and rule.filetypes[1] == "rust"
        end)
        :fold({}, function(acc, v)
          if acc == nil or #acc > 0 then
            return nil
          else
            table.insert(acc, v)
            return acc
          end
        end)
      if rust_single_quote_rules == nil then
        vim.notify(
          "Multiple rules satisfied predicate that should have only matched one unique rule!",
          vim.log.levels.ERROR,
          { title = "nvim-autopairs (config)" }
        )
      elseif #rust_single_quote_rules == 0 then
        vim.notify("No rules satisfied predicate!", vim.log.levels.ERROR, { title = "nvim-autopairs (config)" })
      elseif #rust_single_quote_rules > 1 then
        vim.notify("This should be impossible!", vim.log.levels.ERROR, { title = "nvim-autopairs (config)" })
      else
        rust_single_quote_rules[1]:with_pair(cond.none(), 1)
      end
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    -- v4 dropped the `keymaps` setup option; keymaps are now bound via
    -- <Plug> mappings when the plugin loads, gated by these globals.
    -- See `:h nvim-surround.migrating.v3_to_v4`.
    init = function()
      vim.g.nvim_surround_no_insert_mappings = true

      -- `ys...e` wraps a motion/text-object in a LaTeX environment,
      -- prompting for its name (mirrors classic vim-surround's tex support).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        group = vim.api.nvim_create_augroup("nvim_surround_tex", { clear = true }),
        callback = function()
          require("nvim-surround").buffer_setup({
            surrounds = {
              e = {
                add = function()
                  local config = require("nvim-surround.config")
                  local result = config.get_input("Enter the environment name: ")
                  if result then
                    return { { "\\begin{" .. result .. "}" }, { "\\end{" .. result .. "}" } }
                  end
                end,
              },
            },
          })
        end,
      })
    end,
    keys = {
      { "ys", desc = "Add surrounding" },
      { "yss", desc = "Add surrounding cur line" },
      { "yS", desc = "Add surrounding w/ new lines" },
      { "ySS", desc = "Add surrounding cur line w/ new lines" },
      { "S", desc = "Add surrounding", mode = "x" },
      { "gS", desc = "Add surrounding w/ new lines", mode = "x" },
      { "ds", desc = "Delete surrounding" },
      { "cs", desc = "Change surrounding" },
      { "cS", desc = "Change surrounding w/ new lines" },
    },
    opts = {
      highlight = { duration = math.huge },
    },
  },
}
