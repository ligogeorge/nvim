vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.opt.number = true -- Show absolute line number on the current line
vim.opt.relativenumber = true -- Enable relative line numbers for other lines

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
    {
        "NvChad/NvChad",
        lazy = false,
        branch = "v2.5",
        import = "nvchad.plugins",
    },

    { import = "plugins" },
}, lazy_config)

require("CopilotChat").setup {}
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

require("toggleterm").setup{
    -- Add your configuration options here
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = 'horizontal',
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = 'curved',
        winblend = 3,
        highlights = {
            border = "Normal",
            background = "Normal",
        },
    },
}

vim.schedule(function()
    require "mappings"
end)

-- Autoload .nvim.lua if it exists
local project_config_path = vim.fn.getcwd() .. "/.nvim/init.lua"

if vim.fn.filereadable(project_config_path) == 1 then
    vim.cmd("luafile " .. project_config_path)
end

-- Remove windows style line endings automatically on unix files
vim.api.nvim_create_autocmd("TextChanged", {
    pattern = "*",
    callback = function()
        if vim.bo.fileformat == "unix" then
            vim.cmd [[silent! %s/\r//g]]
        end
    end,
})
