-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- UI Settings (Theme Configuration)
M.ui = {
    theme = "monochrome", -- This theme is working fine, no changes needed here
}

-- Set Bash as the default shell
vim.opt.shell = "/bin/bash"

return M
