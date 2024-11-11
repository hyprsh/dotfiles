local plugins = {}

local lsp = {
  'lua_ls',
  'ts_ls',
  'eslint',
  'tailwindcss',
  'html',
  'yamlls',
  'emmet_ls',
  'jsonls',
}

plugins.lackluster = {
  'slugbyte/lackluster.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('lackluster').setup({
      tweak_background = { normal = 'none' },
      tweak_highlight = {
        ['@keyword'] = { bold = true, italic = true },
        ['@function'] = { link = '@keyword' },
      },
    })
    -- vim.cmd.colorscheme('lackluster')
    vim.cmd.colorscheme('lackluster-hack')
    -- vim.cmd.colorscheme('lackluster-mint')
  end,
}

plugins.plain_theme = {
  'ntk148v/komau.vim',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    vim.cmd('colorscheme komau')
  end,
}

plugins.lsp = {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'onsails/lspkind.nvim' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
    },
    config = function()
      local lsp_zero = require('lsp-zero')

      local lsp_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        -- Disable semantic highlights
        client.server_capabilities.semanticTokensProvider = nil

        -- Key mappings
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', 'cr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({ 'n', 'x' }, 'cf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      end

      lsp_zero.extend_lspconfig({
        sign_text = true,
        lsp_attach = lsp_attach,
        float_border = 'rounded',
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = lsp,
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup({})
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

      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()

      -- Load extra snippets
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({ paths = { './snippets' } })

      cmp.setup({
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'luasnip', keyword_length = 2 },
          { name = 'buffer', keyword_length = 3 },
        },
        -- window = {
        --   completion = cmp.config.window.bordered(),
        --   documentation = cmp.config.window.bordered(),
        -- },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- confirm completion item
          ['<C-y>'] = cmp.mapping.confirm({ select = false }),

          -- trigger completion menu
          ['<C-Space>'] = cmp.mapping.complete(),

          -- scroll up and down the documentation window
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),

          -- navigate between snippet placeholders
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        formatting = {
          format = function(entry, item)
            local color_item = require('nvim-highlight-colors').format(entry, { kind = item.kind })
            item = require('lspkind').cmp_format({ mode = 'symbol' })(entry, item)
            if color_item.abbr_hl_group then
              item.kind_hl_group = color_item.abbr_hl_group
              item.kind = color_item.abbr
            end
            return item
          end,
        },
      })
    end,
  },
}

plugins.aider = {
  {
    'nekowasabi/aider.vim',
    dependencies = 'vim-denops/denops.vim',
    config = function()
      vim.g.aider_command = 'aider --no-auto-commits'
      vim.g.aider_buffer_open_type = 'floating'
      vim.g.aider_floatwin_width = 100
      vim.g.aider_floatwin_height = 20

      vim.api.nvim_create_autocmd('User', {
        pattern = 'AiderOpen',
        callback = function(args)
          vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { buffer = args.buf })
          vim.keymap.set('n', '<Esc>', '<cmd>AiderHide<CR>', { buffer = args.buf })
        end,
      })
      vim.api.nvim_set_keymap('n', '<leader>at', ':AiderRun<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>aa', ':AiderAddCurrentFile<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ar', ':AiderAddCurrentFileReadOnly<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>aw', ':AiderAddWeb<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ax', ':AiderExit<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ai', ':AiderAddIgnoreCurrentFile<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>aI', ':AiderOpenIgnore<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>aI', ':AiderPaste<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>ah', ':AiderHide<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('v', '<leader>av', ':AiderVisualTextWithPrompt<CR>', { noremap = true, silent = true })
    end,
  },
}

plugins.lazygit = {
  'kdheepak/lazygit.nvim',
  cmd = 'LazyGit',
  keys = {
    { '<leader>lg', '<cmd>LazyGit<CR>', desc = 'Open Lazygit' },
  },
}

plugins.avante = {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  lazy = false,
  version = false,
  opts = {
    provider = 'claude',
    auto_suggestions_provider = 'claude',
    claude = {
      -- get api key from bitwarden, otherwise it reads $ANTHROPIC_API_KEY
      -- api_key_name = 'cmd:bw get notes anthropic-api-key',
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
    -- {
    --   'MeanderingProgrammer/render-markdown.nvim',
    --   opts = {
    --     file_types = { 'markdown', 'Avante' },
    --   },
    --   ft = { 'markdown', 'Avante' },
    -- },
  },
}

plugins.codecompanion = {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'hrsh7th/nvim-cmp',
    'nvim-telescope/telescope.nvim',
    { 'stevearc/dressing.nvim', opts = {} },
  },
  config = function()
    require('codecompanion').setup({
      strategies = {
        chat = {
          adapter = 'anthropic',
        },
        inline = {
          adapter = 'copilot',
        },
        agent = {
          adapter = 'anthropic',
        },
      },
    })
    vim.api.nvim_set_keymap('n', '<C-a>', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<C-a>', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<Leader>a', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true, desc = 'CodeCompanion' })
    vim.api.nvim_set_keymap('v', '<Leader>a', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true, desc = 'CodeCompanion' })
    vim.api.nvim_set_keymap('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end,
}

plugins.mini_ai = {
  'echasnovski/mini.ai',
  version = false,
  config = function()
    require('mini.ai').setup({ n_lines = 500 })
  end,
}

plugins.mini_comment = {
  'echasnovski/mini.comment',
  version = false,
  config = function()
    require('mini.comment').setup({})
  end,
}

plugins.mini_surround = {
  'echasnovski/mini.surround',
  config = function()
    require('mini.surround').setup({})
  end,
  version = false,
}

plugins.mini_pairs = {
  'echasnovski/mini.pairs',
  config = function()
    require('mini.pairs').setup({})
  end,
  version = false,
}

plugins.mini_diff = {
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
}

plugins.mini_notify = {
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
}

plugins.mini_clue = {
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
}

plugins.mini_statusline = {
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
}

plugins.oil = {
  'stevearc/oil.nvim',
  lazy = false,
  priority = 1000,
  dependencies = { 'refractalize/oil-git-status.nvim' },
  keys = {
    { '-', '<cmd>Oil<cr>', desc = 'Open Oil file browser' },
    { '\\', '<cmd>Oil<cr>', desc = 'Open Oil file browser' },
  },
  config = function()
    require('oil').setup({
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      watch_for_changes = true,
      show_hidden = true,
      win_options = {
        signcolumn = 'yes:2',
      },
    })
    require('oil-git-status').setup()
  end,
}

plugins.supermaven = {
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
}

plugins.telescope = {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'natecraddock/telescope-zf-native.nvim' },
  },
  keys = {
    { '<leader>fh', '<cmd>Telescope oldfiles<cr>', desc = 'Search file history' },
    { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Search all files' },
    { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Search in project' },
    { '<leader>ds', '<cmd>Telescope diagnostics<cr>', desc = 'Search diagnostics' },
    { '<leader><space>', '<cmd>Telescope current_buffer_fuzzy_find<cr>', desc = 'Buffer local search' },
    { '<leader>?', '<cmd>Telescope keymaps theme=dropdown<cr>', desc = 'Search keymaps' },
    { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Search open files' },
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
}

plugins.treesitter = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      highlight = { enable = true },
      auto_install = true,
    })
  end,
}

plugins.sleuth = { 'tpope/vim-sleuth' }

plugins.nvimTsAutotag = { 'windwp/nvim-ts-autotag', opts = {} }

plugins.conform = {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  config = function()
    require('conform').setup({
      format_on_save = {
        timeout_ms = 500,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        typescript = { 'eslint', 'prettierd', 'prettier' },
        typescriptreact = { 'eslint', 'prettierd', 'prettier' },
        javascript = { 'eslint', 'prettierd', 'prettier' },
        javascriptreact = { 'eslint', 'prettierd', 'prettier' },
      },
    })
  end,
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}

plugins.nvim_highlight_colors = {
  'brenoprata10/nvim-highlight-colors',
  config = function()
    require('nvim-highlight-colors').setup({ render = 'foreground' }) -- virtual/foreground/background
  end,
}

return plugins
