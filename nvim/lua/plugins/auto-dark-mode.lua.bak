return {
  -- swich theme according to system dark/lightmode
  'f-person/auto-dark-mode.nvim',
  priority = 1000,
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      vim.api.nvim_set_option('background', 'dark')
      vim.cmd 'colorscheme tokyonight-storm'
    end,
    set_light_mode = function()
      vim.api.nvim_set_option('background', 'light')
      vim.cmd 'colorscheme tokyonight-day'
    end,
  },
}
