return {
  "supermaven-inc/supermaven-nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("supermaven").setup()
  end,
  keys = {
    { "<leader>sm", "<cmd>Telescope supermaven<cr>", desc = "Supermaven" },
  },
}
