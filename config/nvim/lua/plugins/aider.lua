return {
  "joshuavial/aider.nvim",
  config = function()
    require("aider").setup({
      -- You can add any configuration options here
      -- For now, we'll use the default settings
    })

    -- Set up keybindings
    vim.keymap.set("n", "<leader>aa", "<cmd>AiderAsk<CR>", { desc = "Aider Ask" })
    vim.keymap.set("n", "<leader>ac", "<cmd>AiderChat<CR>", { desc = "Aider Chat" })
    vim.keymap.set("n", "<leader>ae", "<cmd>AiderEdit<CR>", { desc = "Aider Edit" })
    vim.keymap.set("n", "<leader>ar", "<cmd>AiderResetChat<CR>", { desc = "Aider Reset Chat" })
  end,
}
