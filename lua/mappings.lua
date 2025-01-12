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

        -- Move to the main window
        vim.cmd "wincmd l" -- Move to the right window (assuming the file tree is on the left)
        vim.cmd "wincmd k" -- Move to the top window (assuming this is the main editor)

        -- Open the file and jump to the specified line and column
        vim.cmd(string.format("buffer %s", file))
        vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) - 1 })
        vim.cmd "normal! zz" -- Center the cursor vertically
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
map("n", "<leader>fj", "<cmd>Telescope jumplist<CR>", { desc = "telescope view jumplist" })
map({ "n", "v" }, "<leader>cc", "<cmd>CopilotChat<CR>", { desc = "Open Copilot Chat" })
map({ "n", "v" }, "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Explain Copilot Chat" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "n", "nzz", { desc = "Move to next search item and center" })
map("n", "N", "Nzz", { desc = "Move to previous search item and center" })

-- Keep selection after indenting in visual mode
vim.cmd [[
    vnoremap < <gv
    vnoremap > >gv
]]

local opts = { noremap = true, silent = true }

-- Function to switch to the n+1th buffer
_G.switch_to_buffer = function(n)
    local target_buffer = n + 1
    if vim.fn.bufexists(target_buffer) == 1 then
        vim.cmd("buffer " .. target_buffer)
    else
        print("Buffer " .. target_buffer .. " does not exist")
    end
end

-- Create mappings for <leader>a to <leader>t (20 mappings)
local keys = "abcdefghijklmnopqrstuvwxyz"
for i = 1, 26 do
    local key = keys:sub(i, i)
    map("n", "<leader>s" .. key, ":lua switch_to_buffer(" .. i .. ")<CR>", opts)
end

-- LSP mappings with cursor centering
map(
    "n",
    "gd",
    "<cmd>lua vim.lsp.buf.definition()<CR><cmd>lua vim.defer_fn(function() vim.cmd('normal! zz') end, 100)<CR>",
    opts
)
map(
    "n",
    "gr",
    "<cmd>lua vim.lsp.buf.references()<CR><cmd>lua vim.defer_fn(function() vim.cmd('normal! zz') end, 100)<CR>",
    opts
)

-- Shortcut for insert mode: Ctrl + Backspace to delete an entire word
map("i", "<C-H>", "<C-W>", opts)

map("t", "<Esc>", "<C-\\><C-n>", opts) -- Escape from terminal mode

-- Move lines up and down in normal and visual mode
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
