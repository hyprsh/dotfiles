return {
  -- file browser
  'stevearc/oil.nvim',
  lazy = false,
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    win_options = {
      signcolumn = 'yes:2',
    },
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _)
        return name == '..' or name == '.git'
      end,
    },
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
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '\\', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },
}
