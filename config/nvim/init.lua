-- OPTIONS
vim.opt.mouse = 'a'               -- Enable mouse mode
vim.opt.updatetime = 250          -- Faster completion
vim.opt.timeoutlen = 300          -- Faster completion
vim.opt.clipboard = 'unnamedplus' -- Copy to system clipboard
vim.opt.undofile = true           -- Save undo history

-- visual options
vim.opt.ignorecase = true -- Case insensitive searching
vim.opt.smartcase = true -- Case sensitive searching if query contains uppercase chararcters
vim.opt.hlsearch = true -- Highlight search results
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.showmode = false -- Don't show the mode
vim.opt.termguicolors = true -- Use true colors
vim.opt.number = false -- Show line numbers
vim.opt.signcolumn = 'yes' -- Always show signcolumns
vim.opt.breakindent = true -- Enable break indent
vim.opt.list = true -- Show certain whitespaces
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Show whitespaces
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!
vim.opt.cursorline = false -- Highlight the line where the cursor is
vim.opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.laststatus = 3 -- avante

-- fold options
vim.opt.foldmethod = 'expr'                          -- fold based on expression
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- fold based on treesitter
vim.opt.foldtext = 'getline(v:foldstart)'            -- only show the first line of the fold
vim.opt.foldlevel = 99                               -- don't fold anything by default

-- split options
vim.opt.splitright = true
vim.opt.splitbelow = true

-- autoreload & notify
vim.opt.autoread = true

-- AUTOCOMMANDS
--
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

-- KEYMAPS
vim.g.mapleader = ' '
vim.g.maplocalleader = ''

vim.keymap.set({ 'n', 'x' }, 'x', '"_x')
vim.keymap.set({ 'n', 'x' }, 'X', '"_d')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous Diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next Diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- buffer
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save current buffer' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit current window' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete current buffer' })

-- PLUGINS
-- Lazy Plugin Manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out,                            'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- PLUGINS
local plugins = {
  -- avante
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false,
    opts = {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
      claude = {
        api_key_name = 'cmd:bw get notes anthropic-api-key',
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
    },
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      {
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },

  -- cmp
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        sources = { { name = 'nvim_lsp' }, { name = 'path' } },
        snippet = { expand = function(args) vim.snippet.expand(args.body) end, },
        mapping = cmp.mapping.preset.insert({}),
      })
    end,
  },

  -- darkvoid
  {
    'hyprsh/darkvoid.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('darkvoid').setup({
        transparent = true,
        glow = false,
        show_end_of_buffer = false,
      })
      vim.cmd.colorscheme('darkvoid')
    end,
  },

  -- lazygit
  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    keys = {
      { '<leader>lg', '<cmd>LazyGit<CR>', desc = 'Open Lazygit' },
    },
  },

  -- mason
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },

  -- mason-lspconfig
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      local lsp_zero = require('lsp-zero')

      local lsp_attach = function(client, bufnr)
        lsp_zero.buffer_autoformat()
      end

      lsp_zero.extend_lspconfig({
        lsp_attach = lsp_attach,
      })
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'ts_ls', 'eslint', 'html', 'cssls', 'emmet_ls', 'tailwindcss' },
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup({})
          end,
          ['lua_ls'] = function()
            require('lspconfig').lua_ls.setup({
              settings = { Lua = { diagnostics = { globals = { 'vim' } } } },
            })
          end,
          ['tailwindcss'] = function()
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
    end,
  },

  -- mini.ai
  {
    'echasnovski/mini.ai',
    version = false,
    config = function()
      require('mini.ai').setup({ n_lines = 500 })
    end,
  },

  -- mini.comment
  {
    'echasnovski/mini.comment',
    version = false,
    config = function()
      require('mini.comment').setup()
    end,
  },

  -- mini.surround
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('mini.surround').setup()
    end,
  },

  -- mini.pairs
  {
    'echasnovski/mini.pairs',
    version = false,
    config = function()
      require('mini.pairs').setup()
    end,
  },

  -- mini.diff
  {
    'echasnovski/mini.diff',
    version = false,
    config = function()
      require('mini.diff').setup({
        view = {
          signs = { add = '+', change = '~', delete = '-' },
        },
        { 'tpope/vim-sleuth' },
      })
    end,
  },

  -- mini.notify
  {
    'echasnovski/mini.notify',
    version = false,
    lazy = false,
    config = function()
      require('mini.notify').setup({
        lsp_progress = { enable = false },
        content = {
          format = function(notif)
            return notif.msg
          end,
        },
        window = {
          config = {
            border = '',
          },
          max_width_share = 0.382,
          winblend = 100,
        },
      })
      require('mini.notify').make_notify({})
    end,
  },

  -- mini.clue
  {
    'echasnovski/mini.clue',
    version = false,
    config = function()
      local miniclue = require('mini.clue')
      miniclue.setup({
        window = {
          delay = 0,
          config = {
            width = '40',
            border = '',
          },
        },
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      })
    end,
  },
  -- mini.statusline
  {
    'echasnovski/mini.statusline',
    version = false,
    config = function()
      local statusline = require('mini.statusline')
      statusline.setup({ use_icons = true })
      statusline.section_location = function()
        return '%2l:%-2v'
      end
      statusline.section_fileinfo = function()
        return ''
      end
    end,
  },

  -- oil
  {
    'stevearc/oil.nvim',
    lazy = false,
    priority = 1000,
    dependencies = { 'refractalize/oil-git-status.nvim' },
    keys = {
      { '-',  '<cmd>Oil<cr>', desc = 'Open Oil file browser' },
      { '\\', '<cmd>Oil<cr>', desc = 'Open Oil file browser' },
    },
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        win_options = {
          signcolumn = 'yes:2',
        },
      })
      require('oil-git-status').setup()
    end,
  },

  -- supermaven
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup({
        log_level = 'off',
        keymaps = {
          accept_suggestion = '<C-y>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-j>',
        },
        color = {
          suggestion_color = '#ffffff',
        },
      })
    end,
  },

  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'natecraddock/telescope-zf-native.nvim' },
    },
    keys = {
      { '<leader>?',       '<cmd>Telescope oldfiles<cr>',                  desc = 'Search file history' },
      { '<leader><space>', '<cmd>Telescope buffers<cr>',                   desc = 'Search open files' },
      { '<leader>ff',      '<cmd>Telescope find_files<cr>',                desc = 'Search all files' },
      { '<leader>fg',      '<cmd>Telescope live_grep<cr>',                 desc = 'Search in project' },
      { '<leader>ds',      '<cmd>Telescope diagnostics<cr>',               desc = 'Search diagnostics' },
      { '<leader>fs',      '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = 'Buffer local search' },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown({}),
          },
        },
      })
      require('telescope').load_extension('zf-native')
      require('telescope').load_extension('ui-select')
    end,
  },

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        auto_install = true,
      })
    end,
  },

  -- sleuth (detect and adjust indentation)
  { 'tpope/vim-sleuth' },
}

require('lazy').setup(plugins, {})
