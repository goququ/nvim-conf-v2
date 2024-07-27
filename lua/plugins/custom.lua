return {
  { "editorconfig/editorconfig-vim", event = "VeryLazy" },
  { "jparise/vim-graphql", event = "VeryLazy" },
  -- {
  -- 	"windwp/nvim-ts-autotag",
  -- 	opts = {
  -- 		autotag = {
  -- 			enable = true,
  -- 			enable_close_on_slash = false,
  -- 		},
  -- 	}
  -- },
  {
    "tpope/vim-surround",
    event = "VeryLazy",
    -- make sure to change the value of `timeoutlen` if it's not triggering correctly, see https://github.com/tpope/vim-surround/issues/117
    -- setup = function()
    --  vim.o.timeoutlen = 500
    -- end
  },
  { "ethanholz/nvim-lastplace", event = "VeryLazy" },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- Change 'C-g' here to any keycode you like.
      vim.keymap.set("i", "<C-u>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
      vim.keymap.set("i", "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
      vim.keymap.set("i", "<c-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
    end,
  },
  -- {
  -- 	"mattn/emmet-vim",
  -- 	fevent = "VeryLazy",
  -- },
}
