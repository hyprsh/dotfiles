vim.g.mapleader = ' '
vim.opt.wrap = false -- Dont wrap text
vim.opt.cursorline = true -- Highlight the current line
vim.opt.mouse = 'a' -- Enable mouse support
vim.opt.number = true -- Disable absolute line numbers
vim.opt.relativenumber = true -- Disable relative line numbers
vim.opt.hidden = true -- Allow switching buffers without saving
vim.opt.backup = false -- Disable backup files
vim.opt.writebackup = false -- Disable write backup files
vim.opt.swapfile = false -- Disable swap files
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Customize invisible characters
vim.opt.laststatus = 3 -- Use a global statusline
vim.opt.pumheight = 10 -- Limit popup menu height
vim.opt.scrolloff = 3 -- Minimum lines around the cursor vertically
vim.opt.sidescrolloff = 3 -- Minimum columns around the cursor horizontally
vim.opt.updatetime = 250 -- Reduce time for CursorHold events
vim.opt.clipboard = 'unnamedplus' -- Use the system clipboard
vim.opt.inccommand = 'split' -- Preview incremental substitute
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below
vim.opt.showmode = false -- Hide mode display in the statusline
vim.opt.signcolumn = 'yes' -- Always show the sign column
vim.opt.undofile = true -- Enable persistent undo
vim.opt.fillchars = 'eob: ' -- Remove tilde on empty lines
vim.opt.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]] -- use ripgrep for grep
vim.opt.grepformat = vim.opt.grepformat ^ { '%f:%l:%c:%m' } -- config grep
vim.opt.title = true
vim.opt.titlestring = "%t%( %M%)%( (%{expand('%:~:.:h')})%)%( %a%)" -- set title

-- keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>b', '<cmd>FzfLua buffers<cr>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>d', '<cmd>FzfLua diagnostics_document<cr>', { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>f', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>o', '<cmd>FzfLua oldfiles<cr>', { desc = 'Old files' })
vim.keymap.set('n', '<leader>s', '<cmd>FzfLua live_grep_native<cr>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'Lazygit' })
vim.keymap.set('n', '<leader>gt', '<cmd>lua MiniDiff.toggle()<cr>', { desc = 'Toggle git diff' })
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

-- Open FzfLua on start
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if #vim.fn.argv() == 0 then
      require('fzf-lua').files()
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
local function setBackground()
  local m = vim.fn.system('defaults read -g AppleInterfaceStyle'):gsub('%s+', '')
  vim.o.background = (m == 'Dark') and 'dark' or 'light'
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  callback = function()
    setBackground()
  end,
})

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
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'stevearc/conform.nvim',
  'nmac427/guess-indent.nvim',
  'ibhagwan/fzf-lua',
  'kdheepak/lazygit.nvim',
  'nvim-lualine/lualine.nvim',
  'rafamadriz/friendly-snippets',
})

-- colorscheme
vim.g.zenbones = { solid_float_border = true, transparent_background = true }
vim.cmd.colorscheme('zenbones')
setBackground()

require('guess-indent').setup({}) -- detect indentation
require('tree-pairs').setup() -- % respects treesitter nodes
require('mini.ai').setup() -- a/i textobjects
require('mini.bracketed').setup() -- unimpaired bindings with TS
require('mini.comment').setup() -- TS-wise comments
require('mini.completion').setup() -- autocompletions
require('mini.pairs').setup() -- pair brackets
require('mini.surround').setup() -- surrounding
require('mini.splitjoin').setup() -- gS to split or join arguments

-- snippets
local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  snippets = {
    -- gen_loader.from_file('~/.config/nvim/snippets/global.json'),
    gen_loader.from_lang(),
  },
})

-- show keybinds
local miniclue = require('mini.clue')
miniclue.setup({
  window = {
    config = { border = 'none' },
    delay = 200,
  },
  triggers = {
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'i', keys = '<C-x>' },
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = 'z' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '[' },
  },
  clues = {
    { mode = 'n', keys = '<Leader>c', desc = 'Code' },
    { mode = 'n', keys = '<Leader>g', desc = 'Git' },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})
vim.api.nvim_set_hl(0, 'MiniClueBorder', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'MiniClueDescGroup', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'MiniClueDescSingle', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'MiniClueNextKey', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'MiniClueNextKeyWithPostkeys', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'MiniClueSeparator', { link = 'NormalFloat' })
vim.api.nvim_set_hl(0, 'MiniClueTitle', { link = 'NormalFloat' })

-- file explorer
require('oil').setup({
  view_options = { show_hidden = true },
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  watch_for_changes = true,
})

-- file picker
require('fzf-lua').setup({
  'boderless',
  winopts = {
    row = 1,
    height = 0.5,
    width = 1,
    border = false,
    preview = { title = false, scrollbar = false },
  },
  files = { actions = false, previewer = false, cwd_prompt = false },
  oldfiles = { previewer = false },
  fzf_colors = {
    ['gutter'] = '-1',
    ['pointer'] = '-1',
    ['prompt'] = '-1',
    ['fg+'] = { 'fg', 'Normal' },
    ['bg+'] = { 'bg', 'CursorLine' },
    ['hl+'] = { 'fg', 'Comment' },
    ['hl'] = { 'fg', 'Comment' },
  },
})

-- treesitter
require('nvim-treesitter.configs').setup({
  auto_install = true,
  highlight = { enable = true, additional_vim_regex_highlighting = { 'nix' } },
  indent = { enable = true, disable = { 'nix' } },
})

-- notifier
require('mini.notify').setup({
  window = { config = { border = 'none' } },
})

-- diff view
require('mini.diff').setup({
  view = {
    style = 'sign',
    -- signs = { add = '▎', change = '▎', delete = '' },
    signs = { add = '+', change = '~', delete = '_' },
  },
})

-- statusline
require('lualine').setup({
  options = {
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_x = {},
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
