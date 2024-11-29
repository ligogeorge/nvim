vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.opt.number = true        -- Show absolute line number on the current line
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

require("CopilotChat").setup{
}
-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Autoload .nvim.lua if it exists
local project_config_path = vim.fn.getcwd() .. "/.nvim.lua"

if vim.fn.filereadable(project_config_path) == 1 then
    vim.cmd("luafile " .. project_config_path)
end

