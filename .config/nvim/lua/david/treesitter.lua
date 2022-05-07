local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

--configs.setup {
--  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
--  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
--  ignore_install = { "" }, -- List of parsers to ignore installing
--  autopairs = {
--    enable = true,
--  },
--  highlight = {
--    enable = true, -- false will disable the whole extension
--    disable = { "" }, -- list of language that will be disabled
--    additional_vim_regex_highlighting = true,
--  },
--  indent = { enable = true, disable = { "yaml" } },
--  context_commentstring = {
--    enable = true,
--    enable_autocmd = false,
--  },
--}
--


configs.setup {
    ensure_installed = "maintained",
    sync_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    },
--    incremental_selection = {
--        enable = true,
--        keymaps = {
--            init_selection = "<CR>",
--            node_incremental = "<CR>",
--            node_decremental = "<BS>",
--            scope_incremental = "<TAB>"
--        }
--    },
    indent = {
        enable = true,
        disable = { "python", "python3" }
    },
    rainbow = {
        enable = true,
        extended_mode = true
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
    },
    context_commentstring = {
        enable = true
    }
}
