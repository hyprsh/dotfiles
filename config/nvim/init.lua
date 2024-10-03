-- OPTIONS
vim.opt.mouse = 'a' -- Enable mouse mode
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 300 -- Faster completion
vim.opt.clipboard = 'unnamedplus' -- Copy to system clipboard
vim.opt.undofile = true -- Save undo history

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
vim.opt.foldmethod = 'expr' -- fold based on expression
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- fold based on treesitter
vim.opt.foldtext = 'getline(v:foldstart)' -- only show the first line of the fold
vim.opt.foldlevel = 99 -- don't fold anything by default

-- split options
vim.opt.splitright = true
vim.opt.splitbelow = true

-- autoreload & notify
vim.opt.autoread = true

-- AUTOCOMMANDS
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
        if not (ft:match 'commit' and ft:match 'rebase') and last_known_line > 1 and last_known_line <= vim.api.nvim_buf_line_count(opts.buf) then
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
vim.g.mapleader = ' ' -- Space as leader key
vim.g.maplocalleader = '\\' -- Backslash as local leader key

vim.keymap.set({ 'n', 'x' }, 'x', '"_x') -- delete without yanking
vim.keymap.set({ 'n', 'x' }, 'X', '"_d') -- delete without yanking
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- clear search highlight

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
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  { 'echasnovski/mini.nvim', version = false },
  { 'stevearc/oil.nvim', lazy = false },
  { 'nvim-lua/plenary.nvim', build = false },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', build = false },
  { 'natecraddock/telescope-zf-native.nvim', build = false },
  { 'nvim-telescope/telescope-ui-select.nvim' },
  { 'refractalize/oil-git-status.nvim' },

  { 'nvim-treesitter/nvim-treesitter' },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'stevearc/conform.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'j-hui/fidget.nvim' },
  { 'tpope/vim-sleuth' },
  { 'kdheepak/lazygit.nvim' },
  {
    'supermaven-inc/supermaven-nvim',
    opts = {
      log_level = 'off',
      keymaps = {
        accept_suggestion = '<C-y>',
        clear_suggestion = '<C-]>',
        accept_word = '<C-j>',
      },
    },
  },

  {
    'hyprsh/darkvoid.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('darkvoid').setup {
        transparent = true,
        glow = false,
        show_end_of_buffer = false,
      }
      vim.cmd.colorscheme 'darkvoid'
    end,
  },

  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false,
    opts = {
      provider = 'claude',
      auto_suggestions_provider = 'claude',
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
}

-- PLUGIN CONFIGURATION

-- See :help lazyGit
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'Open lazy git' })

-- See :help nvim-treesitter-modules
---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
  highlight = { enable = true },
  auto_install = true,
  ensure_installed = { 'lua', 'vim', 'vimdoc', 'json' },
}

-- See :help cmp-config
local cmp = require 'cmp'
cmp.setup {
  sources = {
    { name = 'nvim_lsp' },
    -- { name = 'buffer' },
    { name = 'path' },
  },
  mapping = cmp.mapping.preset.insert {
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-n>'] = cmp.mapping.select_next_item(),
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
}

-- See :help MiniAi-textobject-builtin
require('mini.ai').setup { n_lines = 500 }

-- See :help MiniComment.config
require('mini.comment').setup {}

-- See :help MiniSurround.config
require('mini.surround').setup {}

-- See :help MiniPairs.config
require('mini.pairs').setup {}

-- See :help MiniIcons.config
require('mini.icons').setup {}

-- See :help MiniIcons.config
require('mini.icons').setup {}

-- See :help MiniBufremove.config
require('mini.bufremove').setup {}

-- Close buffer and preserve window layout
vim.keymap.set('n', '<leader>bc', '<cmd>lua pcall(MiniBufremove.delete)<cr>', { desc = 'Close buffer' })

-- See :help MiniGit.config
require('mini.git').setup {}

-- See :help MiniDiff.config
require('mini.diff').setup {
  view = {
    signs = { add = '+', change = '~', delete = '-' },
  },
}

-- See :help MiniNotify.config
require('mini.notify').setup {
  lsp_progress = { enable = false },
}

-- See :help MiniNotify.make_notify()
vim.notify = require('mini.notify').make_notify {}

local miniclue = require 'mini.clue'
miniclue.setup {
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
    { mode = 'x', keys = 'z' },
  },
  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}

-- See :help MiniStatusline.config
local statusline = require 'mini.statusline'
statusline.setup { use_icons = true }

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

---@diagnostic disable-next-line: duplicate-set-field

statusline.section_fileinfo = function()
  return ''
end

-- See :help oil
require('oil').setup {
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  columns = {},
  win_options = {
    signcolumn = 'yes:2',
  },
}
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open Oil file browser' })
vim.keymap.set('n', '\\', '<cmd>Oil<cr>', { desc = 'Open Oil file browser' })
require('oil-git-status').setup {}

-- See :help telescope.builtin
vim.keymap.set('n', '<leader>?', '<cmd>Telescope oldfiles<cr>', { desc = 'Search file history' })
vim.keymap.set('n', '<leader><space>', '<cmd>Telescope buffers<cr>', { desc = 'Search open files' })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Search all files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Search in project' })
vim.keymap.set('n', '<leader>ds', '<cmd>Telescope diagnostics<cr>', { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>fs', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = 'Buffer local search' })

require('telescope').setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {},
    },
  },
}
require('telescope').load_extension 'zf-native'
require('telescope').load_extension 'ui-select'

-- format
require('conform').setup {
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    typescript = { 'eslint', 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'eslint', 'prettierd', 'prettier', stop_after_first = true },
    javascript = { 'eslint', 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'eslint', 'prettierd', 'prettier', stop_after_first = true },
    python = { 'isort', 'black' },
  },
}
vim.keymap.set('n', '<leader>cf', function()
  require('conform').format { async = true, lsp_fallback = true }
end, { desc = 'Format code' })

-- lspconfig
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = { 'lua_ls', 'ts_ls', 'eslint', 'html', 'cssls', 'emmet_ls', 'tailwindcss' },
}

require('mason-lspconfig').setup_handlers {
  function(server_name) -- default handler (optional)
    require('lspconfig')[server_name].setup {}
  end,
  ['lua_ls'] = function()
    local lspconfig = require 'lspconfig'
    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    }
  end,
  ['tailwindcss'] = function()
    require('lspconfig').tailwindcss.setup {
      settings = {
        tailwindCSS = {
          classAttributes = { 'class', 'className', 'style' },
          experimental = {
            classRegex = { 'tw`([^`]*)', 'tw.style\\(([^)]*)\\)', "'([^']*)'" },
          },
        },
      },
    }
  end,
}

require('fidget').setup {}

local lspconfig = require 'lspconfig'

-- Adds nvim-cmp's capabilities settings to
-- lspconfig's default config
lspconfig.util.default_config.capabilities =
  vim.tbl_deep_extend('force', lspconfig.util.default_config.capabilities, require('cmp_nvim_lsp').default_capabilities())

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
    end

    map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
    map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
    map('gr', require('telescope.builtin').lsp_references, 'Goto References')
    map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
    map('<leader>cd', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
    map('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
    map('<leader>cw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
    map('<leader>cr', vim.lsp.buf.rename, 'Rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
  end,
})
