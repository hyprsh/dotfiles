-- my basic vim setup
-- https://github.com/albingroen/quick.nvim

-- Basic settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.wrap = false
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.laststatus = 3
vim.opt.pumheight = 10
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.clipboard = 'unnamedplus'
vim.opt.inccommand = 'split'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.showmode = false
vim.opt.autoread = true

-- Helpers
local function change_colorscheme()
  local m = vim.fn.system('defaults read -g AppleInterfaceStyle')
  m = m:gsub('%s+', '') -- trim whitespace
  if m == 'Dark' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
end

local function toggle_darkmode()
  if vim.o.background == 'dark' then
    vim.opt.background = 'light'
  else
    vim.opt.background = 'dark'
  end
end

-- Basic mappings
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-H>', '<C-W><C-H>')
vim.keymap.set('n', '<C-J>', '<C-W><C-J>')
vim.keymap.set('n', '<C-K>', '<C-W><C-K>')
vim.keymap.set('n', '<C-L>', '<C-W><C-L>')
vim.keymap.set('n', '<C-S>', ':%s/')
vim.keymap.set('n', 'sp', ':sp<CR>')
vim.keymap.set('n', 'tj', ':tabprev<CR>')
vim.keymap.set('n', 'tk', ':tabnext<CR>')
vim.keymap.set('n', 'tn', ':tabnew<CR>')
vim.keymap.set('n', 'to', ':tabo<CR>')
vim.keymap.set('n', 'vs', ':vs<CR>')
vim.keymap.set('n', '<leader>dj', ':cnext<CR>', { silent = true, desc = 'next errror' })
vim.keymap.set('n', '<leader>dk', ':cprevious<CR>', { silent = true, desc = 'prev error' })
vim.keymap.set('n', '<leader>tc', toggle_darkmode, { silent = true, desc = 'darkmode' })
vim.keymap.set('n', '<leader>tn', '<cmd>set relativenumber!<cr><cmd>set number!<cr>', { silent = true, desc = 'line numbers' })

-- file changed on disk
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  command = 'checktime',
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})

-- restore last cursor position
vim.api.nvim_create_autocmd('BufRead', {
  desc = 'Restore last cursor position',
  callback = function(opts)
    vim.api.nvim_create_autocmd('BufWinEnter', {
      once = true,
      buffer = opts.buf,
      callback = function()
        local ft = vim.bo[opts.buf].filetype
        local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
        if not (ft:match('commit') and ft:match('rebase')) and last_known_line > 1 and last_known_line <= vim.api.nvim_buf_line_count(opts.buf) then
          vim.api.nvim_feedkeys([[g`"]], 'nx', false)
        end
      end,
    })
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Setup lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Install plugins
require('lazy').setup({
  -- Automatic indentation
  'tpope/vim-sleuth',

  -- Autoclose HTML-style tags
  'windwp/nvim-ts-autotag',

  -- Easy commenting in normal & visual mode
  { 'numToStr/Comment.nvim', lazy = false },
  { 'JoosepAlviste/nvim-ts-context-commentstring', event = 'VeryLazy' },

  -- code assistant
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
    },
    build = 'make tiktoken',
    opts = {},
    keys = {
      { '<leader>aa', '<cmd>CopilotChatToggle<cr>', mode = { 'n', 'v' }, desc = 'toggle chat' },
      { '<leader>ae', '<cmd>CopilotChatExplain<cr>', mode = { 'n', 'v' }, desc = 'explain selection' },
      { '<leader>ar', '<cmd>CopilotChatReview<cr>', mode = { 'n', 'v' }, desc = 'review selection' },
      { '<leader>af', '<cmd>CopilotChatFix<cr>', mode = { 'n', 'v' }, desc = 'fix selection' },
      { '<leader>ad', '<cmd>CopilotChatDoc<cr>', mode = { 'n', 'v' }, desc = 'add documentation' },
      { '<leader>ag', '<cmd>CopilotChatFixDiagnostic<cr>', mode = { 'n', 'v' }, desc = 'fix diagnostic' },
      { '<leader>am', '<cmd>CopilotChatCommit<cr>', mode = { 'n', 'v' }, desc = 'write commit message' },
      { '<leader>as', '<cmd>CopilotChatCommitStaged<cr>', mode = { 'n', 'v' }, desc = 'write staged commit message' },
      { '<leader>at', '<cmd>CopilotChatTest<cr>', mode = { 'n', 'v' }, desc = 'write test case' },
    },
  },

  -- copilot completion
  {
    'zbirenbaum/copilot-cmp',
    event = 'InsertEnter',
    config = function()
      require('copilot_cmp').setup()
    end,
    dependencies = {
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      config = function()
        require('copilot').setup({
          suggestion = { enabled = false },
          panel = { enabled = false },
        })
      end,
    },
  },

  -- statusline
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_x = {},
      },
    },
  },

  -- File explorer
  {
    'stevearc/oil.nvim',
    lazy = false,
    config = function()
      require('oil').setup({
        view_options = {
          show_hidden = true,
        },
        default_file_explorer = true,
      })
    end,
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
      { '\\', '<cmd>Oil<cr>', desc = 'Open parent directory' },
    },
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    opts = {
      pickers = {
        grep_string = { previewer = false, theme = 'ivy' },
        diagnostics = { previewer = false, theme = 'ivy' },
        find_files = { previewer = false, theme = 'ivy' },
        buffers = { previewer = false, theme = 'ivy' },
        current_buffer_fuzzy_find = { theme = 'ivy' },
        resume = { previewer = false, theme = 'ivy' },
        live_grep = { theme = 'ivy' },
      },
      defaults = {
        layout_config = {
          prompt_position = 'bottom',
        },
      },
    },
    keys = {
      { '<leader>z', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = 'fuzzy find buffer' },
      { '<leader>e', '<cmd>Telescope diagnostics<cr>', desc = 'diagnostics' },
      { '<leader>w', '<cmd>Telescope grep_string<cr>', desc = 'grep string' },
      { '<leader>f', '<cmd>Telescope find_files<cr>', desc = 'find files' },
      { '<leader>s', '<cmd>Telescope live_grep<cr>', desc = 'live grep' },
      { '<leader>b', '<cmd>Telescope buffers<cr>', desc = 'buffers' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Better syntax highlighting & much more
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local configs = require('nvim-treesitter.configs')

      configs.setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true, enable_close_on_slash = false },
      })
    end,
  },

  -- Colorscheme
  {
    'mcchrish/zenbones.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      change_colorscheme()
      vim.g.zenbones_compat = true
      vim.cmd('colorscheme zenbones')
    end,
  },

  -- Surround words with characters in normal mode
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  -- For formatting code
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        graphql = { 'prettierd' },
        json = { 'prettierd' },
        css = { 'prettierd' },
        lua = { 'stylua' },
      },
      format_on_save = {},
    },
  },

  -- Pair matching characters
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      disable_filetype = { 'TelescopePrompt', 'vim' },
    },
  },

  -- lazygit
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'toggle' },
      { '<leader>gf', '<cmd>LazyGitFilter<cr>', desc = 'filter' },
      { '<leader>gc', '<cmd>LazyGitFilterCurrentFile<cr>', desc = 'filter current' },
    },
  },

  -- git diff
  {
    'echasnovski/mini.diff',
    event = 'VeryLazy',
    version = false,
    keys = {
      {
        '<leader>go',
        function()
          require('mini.diff').toggle_overlay(0)
        end,
        desc = 'diff overlay',
      },
      {
        '<leader>tg',
        function()
          require('mini.diff').toggle()
        end,
        desc = 'toggle git diff',
      },
    },
    opts = {
      view = {
        style = 'sign',
        signs = { add = '▎', change = '▎', delete = '' },
        -- signs = { add = '+', change = '~', delete = '-' },
      },
    },
  },

  -- show keymaps
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 500,
      icons = { mappings = false },
      spec = {
        { '<leader>g', group = 'git' },
        { '<leader>c', group = 'code' },
        { '<leader>a', group = 'assistant' },
        { '<leader>d', group = 'diagnostics' },
        { '<leader>t', group = 'toggles' },
        { '<leader>f', group = 'files' },
      },
    },
  },
})

-- Open Telescope on start
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argv(0) == '' then
      require('telescope.builtin').find_files()
    end
  end,
})

-- Set up Comment.nvim
require('Comment').setup({
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

-- Set up Mason and install set up language servers
require('mason').setup()
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('mason-lspconfig').setup({
  -- available linters: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
  ensure_installed = { 'lua_ls', 'emmet_language_server', 'eslint', 'ts_ls', 'tailwindcss' },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({
        capabilities = capabilities,
      })
    end,
    tailwindcss = function()
      require('lspconfig').tailwindcss.setup({
        settings = {
          tailwindCSS = {
            classAttributes = { 'class', 'className', 'style' },
            experimental = { classRegex = { 'tw`([^`]*)', 'tw.style%(([^)]*)%)', "'([^']*)'" } },
          },
        },
      })
    end,
  },
})

-- Global LSP mappings
vim.keymap.set('n', '<space>de', vim.diagnostic.open_float, { desc = 'open diag' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'next diag' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'prev diag' })
vim.keymap.set('n', '<space>dl', vim.diagnostic.setloclist, { desc = 'open diag list' })

-- More LSP mappings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = 'go to definition' })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = 'show lsp hover' })
    vim.keymap.set('n', '<space>cr', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'rename symbol' })
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'code action' })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = 'go to references' })
  end,
})

-- Set up nvim-cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local luasnip = require('luasnip')
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'luasnip', max_item_count = 3, priority = 500 },
    { name = 'nvim_lsp', max_item_count = 5, priority = 400 },
    { name = 'copilot', max_item_count = 1, priority = 300 },
    { name = 'buffer', max_item_count = 5, priority = 200 },
    { name = 'path', max_item_count = 3, priority = 100 },
  },
  formatting = {
    format = function(_, vim_item)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
      return vim_item
    end,
  },
})

cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
