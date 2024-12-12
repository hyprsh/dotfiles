vim.g.mapleader = ' '
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.scrolloff = 3
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.clipboard = 'unnamedplus'
vim.opt.autoread = true
vim.opt.foldtext = 'v:lua.vim.treesitter.foldtext()'

-- keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>b', '<cmd>Telescope buffers<cr>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>d', '<cmd>Telescope diagnostics<cr>', { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>f', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>s', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>w', '<cmd>Telescope grep_string<cr>', { desc = 'Grep string' })
vim.keymap.set('n', '<leader>z', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = 'Find buffer' })
vim.keymap.set('n', '<leader>g', '<cmd>LazyGit<cr>', { desc = 'Git' })
vim.keymap.set('n', '<leader>o', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

-- Setup lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Install plugins
require('lazy').setup({
  { 'mcchrish/zenbones.nvim', lazy = false },
  { 'rktjmp/lush.nvim', lazy = false },
  { 'stevearc/oil.nvim', lazy = false },
  { 'echasnovski/mini.nvim', version = false },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  'yorickpeterse/nvim-tree-pairs',
  'nvim-telescope/telescope.nvim',
  'nvim-lua/plenary.nvim',
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'stevearc/conform.nvim',
  'tpope/vim-sleuth',
  'folke/which-key.nvim',
  'kdheepak/lazygit.nvim',
  -- 'MunifTanjim/nui.nvim',
  -- 'm4xshen/hardtime.nvim',
})

-- colorscheme
vim.g.zenbones_solid_float_border = true
vim.cmd.colorscheme('zenbones')

-- basic setup
require('mini.basics').setup({
  mappings = { windows = true, move_with_alt = true },
})

require('tree-pairs').setup() -- % respects treesitter nodes
require('mini.ai').setup() -- a/i textobjects
require('mini.bracketed').setup() -- unimpaired bindings with TS
require('mini.comment').setup() -- TS-wise comments
require('mini.completion').setup() -- autocompletions
require('mini.pairs').setup() -- pair brackets
require('mini.surround').setup() -- surrounding
require('mini.splitjoin').setup() -- gS to split or join arguments

-- file explorer
require('oil').setup({
  view_options = { show_hidden = true },
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  watch_for_changes = true,
})

-- file picker
require('telescope').setup({
  pickers = {
    grep_string = { previewer = false, theme = 'ivy' },
    diagnostics = { previewer = false, theme = 'ivy' },
    find_files = { previewer = false, theme = 'ivy', hidden = true },
    buffers = { previewer = false, theme = 'ivy' },
    current_buffer_fuzzy_find = { theme = 'ivy' },
    resume = { previewer = false, theme = 'ivy' },
    live_grep = { theme = 'ivy' },
  },
  defaults = {
    layout_config = { prompt_position = 'bottom' },
  },
})

-- show keybindings
require('which-key').setup({
  preset = 'modern',
  icons = { mappings = false, separator = '', group = '', ellipsis = '…' },
  show_help = false,
  show_keys = false,
  win = { title = false, width = 0.6, padding = { 0, 0 } },
  spec = { { '<leader>c', group = 'Code' } },
})

-- treesitter
require('nvim-treesitter.configs').setup({
  auto_install = true,
  highlight = { enable = true, additional_vim_regex_highlighting = { 'nix' } },
  indent = { enable = true, disable = { 'nix' } },
})

-- minimal statusline
local statusline = require('mini.statusline')
statusline.setup()
statusline.section_location = function()
  return '%2l:%-2v'
end
statusline.section_fileinfo = function()
  return nil
end

-- highlight patterns
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
    todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
    note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

-- lsp
require('mason').setup()
require('mason-lspconfig').setup()
require('mason-lspconfig').setup_handlers({
  function(server_name)
    require('lspconfig')[server_name].setup({})
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { buffer = event.buf, desc = 'Show info' })
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = event.buf, desc = 'Go to definition' })
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', { buffer = event.buf, desc = 'Go to declaration' })
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { buffer = event.buf, desc = 'Go to implenetation' })
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { buffer = event.buf, desc = 'Go to type definition' })
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { buffer = event.buf, desc = 'Go to references' })
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', { buffer = event.buf, desc = 'Go to signature help' })
    vim.keymap.set('n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', { buffer = event.buf, desc = 'Rename symbol' })
    vim.keymap.set({ 'n', 'x' }, '<leader>cf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', { buffer = event.buf, desc = 'Format code' })
    vim.keymap.set('n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<cr>', { buffer = event.buf, desc = 'Code actions' })
  end,
})

-- text formatting
require('conform').setup({
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    javascript = { 'prettierd' },
    typescript = { 'prettierd' },
    json = { 'prettierd' },
    css = { 'prettierd' },
    lua = { 'stylua' },
    sh = { 'shfmt' },
    nix = { 'alejandra' },
  },
  format_on_save = {},
})

-- Open Telescope on start
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if #vim.fn.argv() == 0 then
      require('telescope.builtin').find_files()
    end
  end,
})

-- restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local l = vim.fn.line
    if l('\'"') > 0 and l('\'"') <= l('$') then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 100 })
  end,
})

-- Auto switch to darkmode on focus gain
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  callback = function()
    local m = vim.fn.system('defaults read -g AppleInterfaceStyle'):gsub('%s+', '')
    vim.o.background = (m == 'Dark') and 'dark' or 'light'
  end,
})
