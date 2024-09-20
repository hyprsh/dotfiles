return {
  'supermaven-inc/supermaven-nvim',
  config = function()
    require('supermaven-nvim').setup {
      -- Enable automatic imports
      auto_import = true,
      -- Set up code completion
      completion = {
        enable = true,
        trigger_characters = { '.', ':' },
      },
      -- Configure diagnostics
      diagnostics = {
        enable = true,
        virtual_text = true,
        signs = true,
        underline = true,
      },
      -- Set up formatting
      formatting = {
        enable = true,
        format_on_save = true,
      },
    }
  end,
}
