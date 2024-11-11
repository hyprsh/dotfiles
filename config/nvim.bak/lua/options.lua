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
