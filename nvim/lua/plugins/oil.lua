return {
  -- file browser
  'stevearc/oil.nvim',
  lazy = false,
  opts = {
    delete_to_trash = true,
    preview = {
      border = 'none',
      win_options = {
        winblend = 10,
      },
    },
    float = {
      border = 'none',
      win_options = {
        winblend = 10,
      },
    },
    skip_confirm_for_simple_edits = true,
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '\\', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },
}
