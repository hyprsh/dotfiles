-- Basic settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.wrap = false
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.mouse = 'a'
vim.opt.number = false
vim.opt.relativenumber = false
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
vim.wo.fillchars = 'eob: '

-- Basic mappings
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-H>', '<C-W><C-H>')
vim.keymap.set('n', '<C-J>', '<C-W><C-J>')
vim.keymap.set('n', '<C-K>', '<C-W><C-K>')
vim.keymap.set('n', '<C-L>', '<C-W><C-L>')
vim.keymap.set('n', '<C-S>', ':%s/')
vim.keymap.set('n', 'sp', '<cmd>sp<CR>')
vim.keymap.set('n', 'tj', '<cmd>tabprev<CR>')
vim.keymap.set('n', 'tk', '<cmd>tabnext<CR>')
vim.keymap.set('n', 'tn', '<cmd>tabnew<CR>')
vim.keymap.set('n', 'to', '<cmd>tabo<CR>')
vim.keymap.set('n', 'vs', '<cmd>vs<CR>')
vim.keymap.set('n', '<leader>tn', '<cmd>set relativenumber!<cr><cmd>set number!<cr>', { silent = true, desc = 'line numbers' })

-- File changed on disk
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  command = 'checktime',
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})

-- Set background based on system preference
local function set_background()
  local m = vim.fn.system('defaults read -g AppleInterfaceStyle'):gsub('%s+', '')
  if m == 'Dark' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
end

-- Auto switch to darkmode on focus gain
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    set_background()
  end,
})

-- Restore last cursor position
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

-- Open Telescope on start
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argv(0) == '' then
      require('telescope.builtin').find_files()
    end
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

  -- Code assistant
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

  -- Copilot completion
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },

  -- Statusline
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
    config = function()
      require('mason').setup()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('mason-lspconfig').setup({
        -- available lsp: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
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
      vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'open diag' })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'next diag' })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'prev diag' })
      vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'open diag list' })
      vim.keymap.set('n', '<leader>cm', '<cmd>Mason<cr>', { desc = 'mason' })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = ev.buf, desc = 'go to definition' })
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { buffer = ev.buf, desc = 'go to references' })
          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { buffer = ev.buf, desc = 'show lsp hover' })
          vim.keymap.set({ 'n', 'v' }, '<space>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', { buffer = ev.buf, desc = 'rename symbol' })
          vim.keymap.set({ 'n', 'v' }, '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', { buffer = ev.buf, desc = 'code action' })
          vim.keymap.set({ 'n', 'v' }, '<space>cf', '<cmd>lua vim.lsp.buf.format({ async = true })<cr>', { buffer = ev.buf, desc = 'format' })
        end,
      })
    end,
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      { 'zbirenbaum/copilot-cmp', opts = {} },
      { 'garymjr/nvim-snippets', opts = { friendly_snippets = true }, dependencies = { 'rafamadriz/friendly-snippets' } },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'snippets', max_item_count = 5, priority = 500 },
          { name = 'nvim_lsp', max_item_count = 5, priority = 400 },
          { name = 'copilot', max_item_count = 1, priority = 300 },
          { name = 'buffer', max_item_count = 3, priority = 200 },
          { name = 'path', max_item_count = 3, priority = 100 },
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({}),
        formatting = {
          format = function(entry, item)
            return require('nvim-highlight-colors').format(entry, item)
          end,
        },
      })
    end,
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
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      { 'windwp/nvim-ts-autotag', opts = {} },
    },
    config = function()
      local configs = require('nvim-treesitter.configs')
      configs.setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-space>',
            node_incremental = '<C-space>',
            scope_incremental = false,
            node_decremental = '<bs>',
          },
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
            goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
            goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
            goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
          },
        },
      })
    end,
  },

  -- Colorscheme
  {
    'mcchrish/zenbones.nvim',
    lazy = false,
    priority = 1000,
    dependencies = 'rktjmp/lush.nvim',
    config = function()
      set_background()
      vim.g.zenbones_transparent_background = true
      vim.g.zenwritten_transparent_background = true
      vim.cmd('colorscheme zenbones')
    end,
  },

  -- For formatting code
  {
    'stevearc/conform.nvim',
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        graphql = { 'prettierd' },
        json = { 'prettierd' },
        css = { 'prettierd' },
        lua = { 'stylua' },
        sh = { 'shfmt' },
      },
      format_on_save = {},
    },
  },

  -- flutter
  {
    'nvim-flutter/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    opts = {
      flutter_lookup_cmd = 'asdf where flutter',
    },
  },

  -- lazygit
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'lazygit' },
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
      { '<leader>go', '<cmd>lua MiniDiff.toggle_overlay(0)<cr>', desc = 'diff overlay' },
      { '<leader>tg', '<cmd>lua MiniDiff.toggle()<cr>', desc = 'toggle git diff' },
    },
    opts = {
      view = {
        style = 'sign',
        signs = { add = '▎', change = '▎', delete = '' },
      },
    },
  },

  -- Autopairs
  {
    'echasnovski/mini.pairs',
    version = false,
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
    },
  },

  -- Highlight colors
  {
    'brenoprata10/nvim-highlight-colors',
    opts = { render = 'background' }, -- 'background', 'foreground', 'virtual'
  },

  -- better text objects
  -- {
  --   'echasnovski/mini.ai',
  --   event = 'VeryLazy',
  --   opts = { n_lines = 500 },
  -- },

  -- Context aware comments
  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- Show keymaps
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
      },
    },
  },
})
