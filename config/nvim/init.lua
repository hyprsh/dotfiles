-- leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- set to true if nerdfont is installed
vim.g.have_nerd_font = true

-- options
require 'config.options'

-- keymaps
require 'config.keymaps'

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Initialize lazy.nvim
require("lazy").setup("plugins")
