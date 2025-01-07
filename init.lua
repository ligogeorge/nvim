vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })

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

require("copilot").setup {
    suggestion = { enabled = false },
    panel = { enabled = false },
}

require("copilot_cmp").setup()
require("CopilotChat").setup()

local cmp = require "cmp"
cmp.setup {
    completion = {
        completeopt = "menu,menuone,noinsert,noselect",
        keyword_length = 1,
    },
    sources = {
        { name = "copilot", group_index = 2, max_item_count = 5 },
        { name = "nvim_lsp", group_index = 2, max_item_count = 5 },
        { name = "buffer", group_index = 2, max_item_count = 5 },
        { name = "path", group_index = 2, max_item_count = 5 },
        { name = "cmdline", group_index = 2, max_item_count = 5 },
    },
    mapping = {
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() then
                cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
            else
                fallback()
            end
        end),
        ["<CR>"] = cmp.mapping.confirm { select = false },
        ["<Esc>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.close()
                vim.cmd "stopinsert"
            else
                fallback()
            end
        end, { "i", "s" }),
    },
}

dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

require("toggleterm").setup {
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
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = "curved",
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

require("lualine").setup {
    options = {
        icons_enabled = true,
        theme = "jellybeans", -- Use the vscode theme
        globalstatus = true, -- Use a single statusline for all windows
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
            {
                "filename",
                path = 1,
            },
        },
        lualine_x = { "filetype" },
        lualine_y = {
            {
                "diagnostics",

                -- Table of diagnostic sources, available sources are:
                --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                -- or a function that returns a table as such:
                --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                sources = { "nvim_diagnostic", "coc" },

                -- Displays diagnostics for the defined severity types
                sections = { "error", "warn", "info", "hint" },

                diagnostics_color = {
                    -- Same values as the general color option can be used here.
                    error = "DiagnosticError", -- Changes diagnostics' error color.
                    warn = "DiagnosticWarn", -- Changes diagnostics' warn color.
                    info = "DiagnosticInfo", -- Changes diagnostics' info color.
                    hint = "DiagnosticHint", -- Changes diagnostics' hint color.
                },
                symbols = { error = "E", warn = "W", info = "I", hint = "H" },
                colored = true, -- Displays diagnostics status in color if set to true.
                update_in_insert = false, -- Update diagnostics in insert mode.
                always_visible = false, -- Show diagnostics even if there are none.
            },
        },
        lualine_z = {
            {
                "location",
            },
            {
                "progress",
            },
        },
    },
    tabline = {
        lualine_a = {
            {
                "buffers",
                buffers_color = {
                    active = "lualine_a_normal",
                    inactive = "lualine_a_inactive",
                },
                fmt = function(name, context)
                    local index = context.bufnr - 2
                    local letter = ""
                    if index < 26 then
                        letter = string.char(97 + index) -- Convert index to letter (a, b, c, ...)
                    end
                    return string.format("%s %s", letter, name)
                end,
                max_length = vim.o.columns,
            },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
            function()
                return vim.api.nvim_get_current_buf() - 1
            end,
        }, -- Show tabs at the far right
    },
}

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function open_in_main_editor(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)

    -- Move to the main window
    vim.cmd "wincmd l" -- Move to the right window (assuming the file tree is on the left)
    vim.cmd "wincmd k" -- Move to the top window (assuming this is the main editor)

    -- Open the file in the specified window
    vim.cmd(string.format("edit %s", entry.path))
    if entry.lnum and entry.col then
        vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
    end
    vim.cmd "normal! zz" -- Center the cursor vertically
end

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = open_in_main_editor, -- Override the default action for Enter key
            },
            n = {
                ["<CR>"] = open_in_main_editor, -- Override the default action for Enter key
            },
        },
    },
}

-- Add a shortcut to open and focus the Neotest summary window
vim.keymap.set("n", "<leader>us", function()
    -- Open the Neotest summary
    vim.cmd "Neotest summary"

    -- Focus the Neotest summary window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "neotest-summary" then
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    print "Neotest summary window not found!"
end, { noremap = true, silent = true, desc = "Open and Focus Neotest Summary" })

-- Add a shortcut to open and focus the Neotest summary window
vim.keymap.set("n", "<leader>us", function()
    -- Open the Neotest summary
    vim.cmd "Neotest summary"

    -- Focus the Neotest summary window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "neotest-summary" then
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    print "Neotest summary window not found!"
end, { noremap = true, silent = true, desc = "Open and Focus Neotest Summary" })

vim.keymap.set("n", "<leader>ur", function()
    vim.cmd "Neotest run"
end, { noremap = true, silent = true, desc = "Run Neotest" })

vim.keymap.set("n", "<leader>uo", function()
    vim.cmd "Neotest output"
end, { noremap = true, silent = true, desc = "View Neotest Output" })
