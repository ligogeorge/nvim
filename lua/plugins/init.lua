-- Helper function to load project-specific plugins
local function load_project_plugins()
    local project_plugins_file = vim.fn.getcwd() .. "/.nvim/plugins.lua"
    if vim.fn.filereadable(project_plugins_file) == 1 then
        return dofile(project_plugins_file)
    else
        return {}
    end
end

local plugins = {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },

    {
        'rmagatti/auto-session',
        lazy = false,

        ---enables autocomplete for opts
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
          suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
          -- log_level = 'debug',
        }
    },

    {
        "ThePrimeagen/vim-be-good",
        lazy = false,
        cmd = { "VimBeGood" },
    },

    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
            { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            -- See Configuration section for options
        },
        -- See Commands section for default commands if you want to lazy load on them
    },

    {
        "akinsho/toggleterm.nvim", 
        version = "2.13.0",
        config = true
    },

    {
        "voldikss/vim-floaterm",
        cmd = { "FloatermNew", "FloatermToggle" },
        keys = {
            { "<leader>lg", ":FloatermNew --width=0.9 --height=0.9 --name=lazygit lazygit<CR>", desc = "Open Lazygit" },
        },
        config = function()
            vim.cmd [[
        command! FloatermLazygit FloatermNew --name=lazygit lazygit
        ]]
        end,
    },
}

-- Merge project-specific plugins
vim.list_extend(plugins, load_project_plugins())

return plugins
