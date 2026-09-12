return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup()
            -- install language parsers (replaces ensure_installed)
            require("nvim-treesitter").install({
                "json",
                "toml",
                "yaml",
                "go",
                "javascript",
                "query",
                "typescript",
                "tsx",
                "php",
                "html",
                "css",
                "markdown",
                "markdown_inline",
                "bash",
                "lua",
                "vim",
                "vimdoc",
                "git_config",
                "git_rebase",
                "c",
                "cpp",
                "diff",
                "cuda",
                "cmake",
                "dockerfile",
                "gitignore",
                "astro",
                "python",
                "rust",
                "latex",
                "bibtex",
                "typst",
                "nginx",
                "nix",
            })
            -- enable highlighting + indentation per buffer
            -- (replaces highlight = { enable = true } / indent = { enable = true })
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                    vim.bo[args.buf].indentexpr =
                        "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
    -- autotag was `autotag = { enable = true }` on the old master API;
    -- on `main` it must be the standalone plugin
    {
        "windwp/nvim-ts-autotag",
        opts = {},
    },
}
