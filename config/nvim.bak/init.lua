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

require('options')
require('keymaps')
local plugins = require('plugins')

require('lazy').setup({
  -- plugins.lackluster,
  plugins.plain_theme,
  -- plugins.nvimTsAutotag,
  plugins.lsp,
  -- mini completions
  -- plugins.lazygit,
  -- plugins.avante,
  plugins.mini_ai,
  plugins.mini_comment,
  plugins.mini_surround,
  -- mini bracketed
  -- mini basics
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
  plugins.conform,
  plugins.nvim_highlight_colors,
})
