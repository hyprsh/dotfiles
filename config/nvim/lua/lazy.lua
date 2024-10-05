local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = require('plugins')

require('lazy').setup({
  plugins.theme,
  plugins.lsp,
  plugins.lazygit,
  plugins.avante,
  plugins.mini_ai,
  plugins.mini_comment,
  plugins.mini_surround,
  plugins.mini_pairs,
  plugins.mini_diff,
  plugins.mini_notify,
  plugins.mini_clue,
  plugins.mini_statusline,
  plugins.oil,
  plugins.supermaven,
  plugins.telescope,
  plugins.treesitter,
  plugins.sleuth,
  -- plugins.which_key,
  plugins.conform,
  plugins.nvim_highlight_colors,
})
