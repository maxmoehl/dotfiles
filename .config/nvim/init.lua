local set = vim.opt
local g = vim.g

require('install-packer')
require('plugins')
-- require('plugin-config')

-- By default title is off. Needed for detecting window as neovim instance (sworkstyle)
vim.cmd "set title"
vim.cmd "setlocal spell spelllang=en"

