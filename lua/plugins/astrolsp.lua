-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function consoleLog()
  local variable = vim.fn.expand "<cword>"
  local file_type = vim.bo.filetype
  if file_type == "typescript" or file_type == "typescriptreact" or file_type == "svelte" then
    vim.cmd("normal! oconsole.log('LOG: " .. variable .. "', " .. variable .. ")")
  end
  if file_type == "go" then vim.cmd('normal! ofmt.Printf("\\n-----\\nLOG: %v\\n-----\\n", ' .. variable .. ")") end
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start

      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 10000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
      "graphql",
      "astro",
      "svelte",
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      graphql = {
        cmd = { "graphql-lsp", "server", "-m", "stream" },
        filetypes = { "graphql", "typescriptreact", "typescript", "javascript", "javascriptreact" },
        root_dir = require("lspconfig").util.root_pattern(".graphqlrc*", ".graphql.config.*", "graphql.config.*"),
      },
      astro = {
        filetypes = { "astro" },
        cmd = { "astro-ls", "--stdio" },
        init_options = {
          -- typescript = {},
        },
        root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
      },
      svelte = {
        setup = {
          cmd = { "svelte-language-server", "--stdio" },
          settings = {
            svelte = {
              plugin = {
                typescript = {
                  enabled = true,
                },
              },
            },
          },
        },
        plugin = {
          typescript = {
            enabled = true,
          },
        },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },

        ["<leader>xl"] = { consoleLog, desc = "Console log some variable" },
        -- ["J"] = { "mzJ`z", desc = "" },
        ["n"] = { "nzzzv", desc = "Next match centered" },
        ["N"] = { "Nzzzv", desc = "Prev match centered" },
        ["<C-c>"] = { "<cmd>close<cr>", desc = "Just close command" },
        ["<C-`>"] = { "<cmd>ToggleTerm direction=horizontal size=14<cr>", desc = "Toggle terminal" },
        ["<leader>xa"] = { "ggVG", desc = "Select entire file" },
        ["<C-a>"] = { "ggVG", desc = "Select entire file" },
      },
      i = {
        ["<C-s>"] = { "<Esc><cmd>w!<cr>", desc = "Force write" },
        ["<C-c>"] = { "<cmd>close<cr>", desc = "Just close command" },
      },
      v = {
        ["<C-a>"] = { "ggVG", desc = "Select entire file" },
        ["<leader>xl"] = { consoleLog, desc = "Console log some variable" },
        ["<C-s>"] = { "<Esc><cmd>w!<cr>", desc = "Force write" },
        ["J"] = { ":m '>+1<CR>gv=gv", desc = "Move line bottom" },
        ["K"] = { ":m '<-2<CR>gv=gv", desc = "Move line top" },
        ["<C-d>"] = { "<C-d>zz", desc = "" },
        ["<C-u>"] = { "<C-u>zz", desc = "" },
        ["<C-c>"] = { "<cmd>close<cr>", desc = "Just close command" },
      },
      x = {
        ["<C-s>"] = { "<Esc><cmd>w!<cr>", desc = "Force write" },
        ["p"] = { [["_dP]], desc = "Enhance paste" },
      },
      t = {
        ["<C-n>"] = { [[<C-\><C-n>]], desc = "Change terminal mode to normal" },
        ["<C-`>"] = { "<cmd>ToggleTerm direction=horizontal size=14<cr>", desc = "Toggle terminal" },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
