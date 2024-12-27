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

        -- Switch to the main editor window
        vim.cmd "wincmd w"

        -- Open the file and jump to the specified line and column
        vim.cmd(string.format("edit %s", file))
        vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) - 1 })
    else
        print "No valid file:row:column found in the current line"
    end
end

-- Map the function to a key combination, e.g., <leader>j
map("n", "<leader>j", jump_to_location_from_terminal, { desc = "Jump to file:row:column from terminal" })

map("v", "<leader>fw", function()
    -- Yank the selected text to the unnamed register
    vim.cmd 'normal! "vy'
    -- Get the selected text from the unnamed register
    local text = vim.fn.getreg '"'
    -- Strip out newlines from the selected text
    text = string.gsub(text, "\n", " ")
    -- Use Telescope's live_grep with the selected text as the default search string
    require("telescope.builtin").live_grep { default_text = text }
end, { desc = "Live grep selected text with Telescope" })

map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "telescope search document symbols" })
map("n", "<leader>fg", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope search current buffer" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "n", "nzz", { desc = "Move to next search item and center" })
map("n", "N", "Nzz", { desc = "Move to previous search item and center" })
