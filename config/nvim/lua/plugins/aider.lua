return {
  'joshuavial/aider.nvim',
  description = "Neovim plugin for Aider, an AI-powered coding assistant",
  config = function()
    require('aider').setup {
      -- -- set a keybinding for the AiderOpen function
      vim.api.nvim_set_keymap('n', '<leader>aa', '<cmd>lua AiderOpen()<cr>', { noremap = true, silent = true }),
      -- set a keybinding for the AiderBackground function
      vim.api.nvim_set_keymap('n', '<leader>ab', '<cmd>lua AiderBackground()<cr>', { noremap = true, silent = true }),
    }
  end,
}
