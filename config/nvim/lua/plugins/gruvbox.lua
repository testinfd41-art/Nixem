return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- Load before other plugins
    config = function()
      require("tokyonight").setup({
        style = "night", -- "storm", "moon", "night" or "day"
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        dim_inactive = false,
        lualine_bold = true,
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
