require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

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

-- Function to jump to file:row:column from terminal
local function jump_to_location_from_terminal()
    local line = vim.api.nvim_get_current_line()
    local file, row, col = string.match(line, "([^%s]+):(%d+):(%d+)")
    if file and row and col then
        -- Convert relative path to absolute path
        if not vim.loop.fs_stat(file) then
            file = vim.fn.getcwd() .. "/" .. file
        end
        vim.cmd "wincmd w" -- Switch to the main editor window
        vim.cmd(string.format("edit +%s %s", row, file))
        vim.cmd(string.format("normal! %sG%s|", row, col))
    else
        print "No valid file:row:column found in the current line"
    end
end

-- Map the function to a key combination, e.g., <leader>j
map("n", "<leader>j", jump_to_location_from_terminal, { desc = "Jump to file:row:column from terminal" })
