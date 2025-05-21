local ts = vim.treesitter
local ls = require('luasnip')
local d = ls.dynamic_node
local i = ls.insert_node
local s = ls.snippet_node
local t = ls.text_node

local helper = require('typstar.autosnippets')
local utils = require('typstar.utils')
local math = helper.in_math
local snip = helper.snip

local snippets = {}

local operations = { -- first boolean: existing brackets should be kept; second boolean: brackets should be added
    { 'vi', '1/', '', true, false },
    { 'bb', '(', ')', true, false }, -- add round brackets
    { 'sq', '[', ']', true, false }, -- add square brackets
    { 'st', '{', '}', true, false }, -- add curly brackets
    { 'bB', '(', ')', false, false }, -- replace with round brackets
    { 'ang', 'angle.l ', ' angle.r', false, false }, -- add angle
    { 'sQ', '[', ']', false, false }, -- replace with square brackets
    { 'BB', '', '', false, false }, -- remove brackets
    { 'ss', '"', '"', false, false },
    { 'abs', 'abs', '', true, true },
    { 'ul', 'underline', '', true, true },
    { 'ol', 'overline', '', true, true },
    { 'ub', 'underbrace', '', true, true },
    { 'ob', 'overbrace', '', true, true },
    { 'bo', 'bold', '', true, true },
    { 'ht', 'hat', '', true, true },
    { 'ar', 'arrow', '', true, true }, -- added vector arrow
    { 'br', 'macron', '', true, true },
    { 'dt', 'dot', '', true, true },
    { 'dou', 'dot.double', '', true, true }, -- added double dot
    { 'ci', 'circle', '', true, true },
    { 'td', 'tilde', '', true, true },
    { 'nr', 'norm', '', true, true },
    { 'vv', 'vec', '', true, true },
    { 'rot', 'rot', '', true, true }, -- add rot
    { 'div', 'div', '', true, true }, -- add div
    { 'grad', 'grad', '', true, true }, -- add grad
    { 'sgn', 'sign', '', true, true }, -- add sign
    { 'rt', 'sqrt', '', true, true },
    { 'flo', 'floor', '', true, true },
    { 'cei', 'ceil', '', true, true },
}

-- TODO: understand this logic and make it more efficient

local ts_wrap_query = ts.query.parse('typst', '[(call) (ident) (letter) (number)] @wrap')
local ts_wrapnobrackets_query = ts.query.parse('typst', '(group) @wrapnobrackets')

local process_ts_query = function(bufnr, cursor, query, root, insert1, insert2, cut_offset)
    for _, match, _ in query:iter_matches(root, bufnr, cursor[1], cursor[1] + 1) do
        if match then
            local start_row, start_col, end_row, end_col = utils.treesitter_match_start_end(match)
            if end_row == cursor[1] and end_col == cursor[2] then
                vim.schedule(function() -- to not interfere with luasnip
                    local cursor_offset = 0
                    local old_len1, new_len1 = utils.insert_text(bufnr, start_row, start_col, insert1, 0, cut_offset)
                    if start_row == cursor[1] then cursor_offset = cursor_offset + (new_len1 - old_len1) end
                    local old_len2, new_len2 =
                        utils.insert_text(bufnr, end_row, cursor[2] + cursor_offset, insert2, cut_offset, 0)
                    if end_row == cursor[1] then cursor_offset = cursor_offset + (new_len2 - old_len2) end
                    vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] + cursor_offset })
                end)
                return true
            end
        end
    end
    return false
end

local smart_wrap = function(args, parent, old_state, expand)
    local bufnr  = vim.api.nvim_get_current_buf()
    local cursor = utils.get_cursor_pos()
    local root   = utils.get_treesitter_root(bufnr)

    -- figure out the left/right wrapper pieces
    local left  = expand[5] and (expand[2] .. '(') or expand[2]
    local right = expand[5] and (expand[3] .. ')') or expand[3]

    -- 1) if you actually selected text, just wrap that
    if #parent.env.LS_SELECT_RAW > 0 then
        return s(nil, {
            t(left),
            t(table.concat(parent.env.LS_SELECT_RAW)),
            t(right),
        })
    end

    -- helper to grab a TS match (text + its extents)
    local function find_match(query)
        for _, match, _ in query:iter_matches(root, bufnr, cursor[1], cursor[1] + 1) do
            if match then
                local sr, sc, er, ec = utils.treesitter_match_start_end(match)
                if er == cursor[1] and ec == cursor[2] then
                    local lines = vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
                    return {
                        text      = table.concat(lines, ''),
                        start_row = sr,
                        start_col = sc,
                        end_row   = er,
                        end_col   = ec,
                    }
                end
            end
        end
    end

    -- 2) try a no-brackets query, then the normal wrap query
    local m = find_match(ts_wrapnobrackets_query) or find_match(ts_wrap_query)
    if m then
        -- only if the character just before the cursor is alphanumeric
        local col = cursor[2]
        if col > 0 then
            local char = vim.api.nvim_buf_get_text(bufnr, cursor[1], col - 1, cursor[1], col, {})[1]
            if char:match('%w') then
                -- delete the old text...
                vim.schedule(function()
                    vim.api.nvim_buf_set_text(
                        bufnr,
                        m.start_row, m.start_col,
                        m.end_row,   m.end_col,
                        {}
                    )
                end)
                -- ...and return the wrapped snippet
                return s(nil, {
                    t(left),
                    t(m.text),
                    i(1),
                    t(right),
                })
            end
        end
    end

    -- 3) fallback: no selection, no valid match → default placeholder
    return s(nil, {
        t(left),
        i(1),
        t(right),
    })
end

for _, val in pairs(operations) do
    table.insert(snippets, snip(val[1], '<>', { d(1, smart_wrap, {}, { user_args = { val } }) }, math, 1500, false))
end

return {
    unpack(snippets),
}

