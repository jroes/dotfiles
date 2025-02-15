return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',

      -- Automatically install LSPs and related tools to stdpath for Neovim
      --  NOTE: Must be loaded before dependants
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      'j-hui/fidget.nvim',

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      'folke/neodev.nvim',

      -- Required so that we can do some LSP + telescope searches
      'nvim-telescope/telescope.nvim',
    },

    config = function()
      -- This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Lets us more easily define mappings specific
          -- for LSP related items.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('<leader>gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map('<leader>gf', vim.lsp.buf.format, '[G] [F]ormat')

          -- NOTE: Moved to fzf-lua
          -- Jump to the definition of the word under your cursor. (To jump back, press <C-t>.)
          -- map('<leader>gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- NOTE: Moved to fzf-lua
          -- Find references for the word under your cursor.
          -- map('<leader>gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- NOTE: Moved to fzf-lua
          -- Jump to the implementation of the word under your cursor.
          --map('<leader>gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- NOTE: Moved to fzf-lua
          -- Jump to the type of the word under your cursor.
          --map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- NOTE: Moved to fzf-lua
          -- Toggle inlay hints
          -- map('<leader>th', function()
          --   vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          -- end, '[T]oggle inlay [H]ints')

          -- NOTE: I moved this to `telescope.lua` to take advantage of the dropdown themeyy
          -- -- Fuzzy find all the symbols in your current document.
          -- map('<leader>ssd', require('telescope.builtin').lsp_document_symbols, '[S]earch [S]ymbols [D]ocument')

          -- NOTE: I moved this to `telescope.lua` to take advantage of the dropdown themeyy
          -- -- Fuzzy find all the symbols in your current workspace.
          -- --  Similar to document symbols, except searches over your entire project.
          -- map('<leader>ssw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]earch [S]ymbols [W]orkspace')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Goto Declaration. For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Make hovering windows display more nicely
          local hover_opts = {
            focusable = false,
            close_events = {
              'BufLeave',
              'CursorMoved',
              'InsertEnter',
              'FocusLost',
            },
            border = 'rounded',
            -- source = 'always',
            -- prefix = ' ',
            -- scope = 'cursor',
          }
          vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, hover_opts)

          -- Show line diagnostics automatically in hover window, while preventing
          -- the cursor from getting stuck in the dialog (focusable = false).
          -- See: https://github.com/vh205/dotfiles/blob/master/nvim/lua/lsp-config/init.lua
          vim.o.updatetime = 250
          vim.api.nvim_create_autocmd('CursorHold', {
            buffer = event.buf,
            callback = function()
              vim.diagnostic.open_float(nil, hover_opts)
            end,
          })
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Setup Mason
      require('mason').setup()
      require('mason-lspconfig').setup()
      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua_ls',
          'stylua',
          -- 'lua-language-server',
        },
        integrations = {
          ['mason-lspconfig'] = true,
        },
      }

      -- WARN: This might be on startup. Delete if so.
      -- vim.cmd 'MasonToolsUpdateSync'

      -- Setup basedpyright for Python projects
      require('lspconfig').basedpyright.setup {
        capabilities = capabilities,
        settings = {
          basedpyright = {
            typeCheckingMode = 'standard',
          },
        },
      }

      -- Setup lua_ls for lua projects
      require('lspconfig').lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = {
              disable = { 'missing-fields' },
              globals = { 'vim' },
            },
          },
        },
      }

      -- Setup rust_analyzer for Rust projects
      require('lspconfig').rust_analyzer.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = 'clippy',
            },
          },
        },
        on_attach = function(client, bufnr)
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
      }

      local function get_ruby_path()
        return vim.fn.trim(vim.fn.system 'asdf which ruby-lsp')
      end

      local lspconfig = require 'lspconfig'
      lspconfig.ruby_lsp.setup {
        capabilities = capabilities,
        cmd = { get_ruby_path() },
        filetypes = { 'ruby' },
        root_dir = lspconfig.util.root_pattern('Gemfile', '.git'),
      }
      -- Get the correct Ruby version from asdf

      -- {
      --   handlers = {
      --     function(server_name)
      --       local server = servers[server_name] or {}
      --       -- This handles overriding only values explicitly passed
      --       -- by the server configuration above. Useful when disabling
      --       -- certain features of an LSP (for example, turning off formatting for tsserver)
      --       server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      --       require('lspconfig')[server_name].setup(server)
      --     end,
      --   },
      -- }
    end,
  },
}
