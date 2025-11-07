vim.g.mapleader     = ' '
vim.o.undofile      = true
vim.o.clipboard     = "unnamedplus"
vim.o.laststatus    = 3
vim.opt.expandtab   = true
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = -1
vim.opt.hidden      = true -- Allow switching buffers without saving
vim.opt.signcolumn  = 'yes' -- Always show the sign column
vim.opt.scrolloff   = 3 -- Minimum lines around the cursor vertically
vim.opt.list        = true -- Show invisible characters
vim.opt.listchars   = { tab = '» ', trail = '·', nbsp = '␣' } -- Customize invisible characters
vim.opt.inccommand  = 'split' -- Preview incremental substitute
vim.opt.showmode    = false
-- vim.opt.wrap = false -- Dont wrap text
-- vim.opt.cursorline = true -- Highlight the current line
-- vim.opt.number = false -- Disable absolute line numbers
-- vim.opt.pumheight = 10 -- Limit popup menu height
-- vim.opt.updatetime = 250 -- Reduce time for CursorHold events
vim.opt.splitright  = true -- Open vertical splits to the right
vim.opt.splitbelow  = true -- Open horizontal splits below
-- vim.opt.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]] -- use ripgrep for grep
-- vim.opt.grepformat = vim.opt.grepformat ^ { '%f:%l:%c:%m' } -- config grep
vim.opt.title       = true
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
vim.keymap.set('n', '<leader>go', '<cmd>lua MiniDiff.toggle_overlay()<cr>', { desc = 'Toggle git diff overlay' })
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
    -- vim.o.background = (m == 'Dark') and 'dark' or 'light'
    if m == 'Dark' then
        vim.o.background = 'dark'
        vim.cmd('colorscheme github_dark_default')
    else
        vim.o.background = 'light'
        vim.cmd('colorscheme github_light_default')
    end
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
    callback = function()
        setBackground()
    end,
})

-- Install plugins with Neovim's native package manager (0.12+)
if not vim.pack then
    error('vim.pack is unavailable. Please use Neovim 0.12 or newer.')
end

local pack_specs = {
    'projekt0n/github-nvim-theme',
    'stevearc/oil.nvim',
    'echasnovski/mini.nvim',
    'nvim-treesitter/nvim-treesitter',
    { src = 'saghen/blink.cmp', version = vim.version.range('1.*') },
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'stevearc/conform.nvim',
    'ibhagwan/fzf-lua',
    'kdheepak/lazygit.nvim',
    'rafamadriz/friendly-snippets',
}

vim.pack.add(pack_specs, { confirm = false })

-- colorscheme
require('github-theme').setup({ options = { transparent = true } })
vim.cmd.colorscheme('github_dark_default')
setBackground()

require('mini.ai').setup()         -- a/i textobjects
require('mini.bracketed').setup()  -- unimpaired bindings with TS
require('mini.completion').setup() -- autocompletions
require('mini.pairs').setup()      -- pair brackets

-- file explorer
require('oil').setup({
    view_options = { show_hidden = true },
    default_file_explorer = true,
    skip_confirm_for_simple_edits = true,
    watch_for_changes = true,
})

-- file picker
require('fzf-lua').setup({
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
require('mini.diff').setup()

-- statusline
require('mini.statusline').setup()

-- lsp
require('mason').setup()
require('mason-lspconfig').setup()

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
