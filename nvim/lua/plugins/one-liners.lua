return {
    { -- This helps with php/html for indentation
        'captbaritone/better-indent-support-for-php-with-html',
    },
    { -- This helps with ssh tunneling and copying to clipboard
        'ojroques/vim-oscyank',
    },
    { -- Git plugin
        'tpope/vim-fugitive',
    },
    { -- Show historical versions of the file locally
        'mbbill/undotree',
    },
    { -- Show CSS Colors
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
    {
      'mrcjkb/rustaceanvim',
      version = '^6', -- Recommended
      lazy = false, -- This plugin is already lazy
      config = function()
          -- Pin rust-analyzer to the exact toolchain that RUST_SRC_PATH points at
          -- (set by the project's nix devshell). This avoids picking up a
          -- generic-linux rust-analyzer from PATH -- Mason's, or the Claude Code
          -- rust-analyzer-lsp plugin -- which NixOS cannot execute (stub-ld error).
          -- It also guarantees the binary matches the std source it analyzes.
          local ra_cmd = nil
          local src = vim.env.RUST_SRC_PATH
          if src then
              local toolchain = src:gsub("/lib/rustlib/src/rust/library/?$", "")
              local candidate = toolchain .. "/bin/rust-analyzer"
              if vim.fn.executable(candidate) == 1 then
                  ra_cmd = { candidate }
              end
          end

          vim.g.rustaceanvim = {
              server = {
                  -- Explicit binary from the devshell toolchain when available,
                  -- else fall back to rustaceanvim's default PATH lookup.
                  cmd = ra_cmd,
                  -- Feed nvim-cmp completion capabilities to rust-analyzer
                  capabilities = require('cmp_nvim_lsp').default_capabilities(),
                  default_settings = {
                      ['rust-analyzer'] = {
                          -- Show all inlay hint kinds
                          inlayHints = {
                              bindingModeHints = { enable = true },
                              closureReturnTypeHints = { enable = 'always' },
                              lifetimeElisionHints = { enable = 'always', useParameterNames = true },
                              parameterHints = { enable = true },
                              typeHints = { enable = true },
                          },
                          -- Run clippy on save for richer diagnostics
                          checkOnSave = true,
                          check = { command = 'clippy' },
                          cargo = { allFeatures = true, loadOutDirsFromCheck = true },
                          procMacro = { enable = true },
                      },
                  },
              },
          }
      end,
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
}
