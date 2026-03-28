-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out, 'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    spec = {
        {
            'nvim-mini/mini.nvim',
            version = '*',
            lazy = false,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            build = ':TSUpdate',
            branch = 'main',
            config = function()
                require('nvim-treesitter').setup({ install_dir = vim.fn.stdpath('data') .. '/ts' })
                require('nvim-treesitter').install({ 'typst' })
            end,
            lazy = false,
            priority = 5000,
        },
        {
            'arne314/typstar',
            dev = true,
            dir = '.',
            name = 'typstar',
            dependencies = {
                {
                    'L3MON4D3/LuaSnip',
                    version = 'v2.*',
                    build = 'make install_jsregexp',
                },
            },
        },
    },
    checker = { enabled = true },
})
dofile('lua/tests/basic_init.lua')
