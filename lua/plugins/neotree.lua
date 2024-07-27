return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "Neotree",
  opts = {
    window = {
      width = 20,
      auto_expand_width = true,
    },
    filesystem = {
      filtered_items = {
        visible = true,
      },
      window = {
        mappings = {
          ["<C-f>"] = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              require("telescope.builtin").live_grep { cwd = node.path }
            else
              print "Not a directory"
            end
          end,
          ["<C-p>"] = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" then
              local target_directory = node.path
              -- Open Telescope in ~/Downloads
              require("telescope.builtin").find_files {
                cwd = "~/Downloads",
                attach_mappings = function(prompt_bufnr, map)
                  -- Override the default select action
                  map("i", "<CR>", function()
                    local selection = require("telescope.actions.state").get_selected_entry()
                    require("telescope.actions").close(prompt_bufnr)
                    -- Copy the selected file to the target directory
                    local source_file = selection.path
                    local cmd = string.format("cp '%s' '%s'", source_file, target_directory)
                    vim.fn.system(cmd)
                    -- Optionally, refresh Neo-tree to show the copied file
                    require("neo-tree.sources.manager").refresh "filesystem"
                  end)
                  return true
                end,
              }
            else
              print "Not a directory"
            end
          end,
        },
      },
    },
  },
}
