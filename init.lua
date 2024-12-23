vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.opt.number = true -- Show absolute line number on the current line
vim.opt.relativenumber = true -- Enable relative line numbers for other lines
vim.opt.shell = "/bin/bash"

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

require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
})

require("copilot_cmp").setup()
require("CopilotChat").setup()

local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
  end

local cmp = require("cmp")
cmp.setup({
    sources = {
      { name = "copilot", group_index = 2 },
      { name = "nvim_lsp", group_index = 2 },
      { name = "buffer", group_index = 2 },
      { name = "path", group_index = 2 },
      { name = "cmdline", group_index = 2 },
    },
    mapping = {
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
          if cmp.visible() and has_words_before() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end),
    },
})

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
