return {
    {
        'L3MON4D3/LuaSnip',
        dependencies = {
            'rafamadriz/friendly-snippets',
            config = function()
                require('luasnip.loaders.from_vscode').lazy_load()
            end,
        },
        opts = {
            history = true,
            delete_check_events = 'TextChanged',
        },
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-emoji',
        },
        event = 'InsertEnter',
        opts = function()
            vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })

            local cmp = require 'cmp'
            local snip_status_ok, luasnip = pcall(require, 'luasnip')
            local icons = require 'lib.icons'

            if not snip_status_ok then
                return
            end

            local border_opts = {
                border = 'single',
                winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
            }

            local function has_words_before()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api
                            .nvim_buf_get_lines(0, line - 1, line, true)[1]
                            :sub(col, col)
                            :match '%s'
                        == nil
            end

            return {
                preselect = cmp.PreselectMode.None,
                formatting = {
                    fields = { 'kind', 'abbr', 'menu' },
                    format = function(entry, item)
                        local max_width = 0
                        local source_names = {
                            nvim_lsp = '(LSP)',
                            path = '(Path)',
                            luasnip = '(Snippet)',
                            buffer = '(Buffer)',
                        }
                        local duplicates = {
                            buffer = 1,
                            path = 1,
                            nvim_lsp = 0,
                            luasnip = 1,
                        }
                        local duplicates_default = 0
                        if max_width ~= 0 and #item.abbr > max_width then
                            item.abbr = string.sub(item.abbr, 1, max_width - 1) .. icons.ui.Ellipsis
                        end
                        item.kind = icons.kind[item.kind]
                        item.menu = source_names[entry.source.name]
                        item.dup = duplicates[entry.source.name] or duplicates_default
                        return item
                    end,
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                duplicates = {
                    nvim_lsp = 1,
                    luasnip = 1,
                    cmp_tabnine = 1,
                    buffer = 1,
                    path = 1,
                },
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
                window = {
                    completion = cmp.config.window.bordered(border_opts),
                    documentation = cmp.config.window.bordered(border_opts),
                },
                mapping = {
                    ['<PageUp>'] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Select,
                        count = 8,
                    },
                    ['<PageDown>'] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Select,
                        count = 8,
                    },
                    ['<C-PageUp>'] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Select,
                        count = 16,
                    },
                    ['<C-PageDown>'] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Select,
                        count = 16,
                    },
                    ['<S-PageUp>'] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Select,
                        count = 16,
                    },
                    ['<S-PageDown>'] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Select,
                        count = 16,
                    },
                    ['<Up>'] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Select,
                    },
                    ['<Down>'] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Select,
                    },
                    ['<C-p>'] = cmp.mapping.select_prev_item {
                        behavior = cmp.SelectBehavior.Insert,
                    },
                    ['<C-n>'] = cmp.mapping.select_next_item {
                        behavior = cmp.SelectBehavior.Insert,
                    },
                    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
                    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
                    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
                    ['<C-y>'] = cmp.config.disable,
                    ['<C-e>'] = cmp.mapping {
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    },
                    ['<CR>'] = cmp.mapping.confirm { select = false },
                    -- auto select first item
                    ['<S-CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    -- auto select first snippet item
                    ['<C-CR>'] = cmp.mapping(function()
                        luasnip.expand_or_jump()
                    end),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                }, {
                    { name = 'buffer' },
                    { name = 'emoji' },
                }),
            }
        end,
    },
}
