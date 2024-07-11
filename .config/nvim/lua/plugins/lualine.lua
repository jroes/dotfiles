return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
                icons_enabled = true,
                theme = 'tokyonight',
                component_separators = {'|', '|'},
                -- component_separators = {'', ''},
                section_separators = {'', ''},
                -- section_separators = {'', ''},
                disabled_filetypes = {}
            },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch'},
            lualine_c = {'filename'},
            lualine_x = {},
            lualine_y = {'filetype'},
            lualine_z = {'location'}
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {},
        extensions = {}
    },
}
