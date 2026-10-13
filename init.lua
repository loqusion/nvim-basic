-- Minimal config for slow/remote machines.
-- Use alongside a full config with: NVIM_APPNAME=nvim-basic nvim

if vim.loader then
  vim.loader.enable()
end

-- Leaders must be set before lazy.nvim loads plugins (and their keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = [[\]]

require("config.options")
require("config.autocmds")
require("config.lazy")
require("config.keymaps")
