require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Remove nvchad theme switcher
vim.keymap.del("n", "<leader>th")

-- Toggle NvimTree with <leader>e
map("n", "<leader>e", function()
    local view = require "nvim-tree.view"
    if view.is_visible() then
        vim.cmd "NvimTreeClose" -- Close the tree if it's open
    else
        vim.cmd "NvimTreeOpen" -- Open the tree if it's closed
    end
end, { desc = "Toggle NvimTree Window" })

-- Toggle focus between NvimTree and editor
map("n", "<leader>t", function()
    local view = require "nvim-tree.view"
    if view.is_visible() then
        if vim.api.nvim_get_current_win() == view.get_winnr() then
            vim.cmd "wincmd p" -- Move focus to the previous window
        else
            vim.cmd "NvimTreeFocus" -- Focus back on NvimTree
        end
    else
        vim.cmd "NvimTreeFocus" -- Open and focus on NvimTree
    end
end, { desc = "Toggle Focus Between Tree and Editor" })
