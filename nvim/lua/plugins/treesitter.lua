return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                -- enable syntax highlighting
                highlight = {
                    enable = true,
                },
                -- enable indentation
                indent = { enable = true },
                -- enable autotagging (w/ nvim-ts-autotag plugin)
                autotag = { enable = true },
                -- ensure these language parsers are installed
                ensure_installed = {
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
		    "bash",
		    "tmux",
		    "nginx",
		    "nix",
                },
                -- auto install above language parsers
                auto_install = false,
            })
        end
    }
}
