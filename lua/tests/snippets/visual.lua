local helper = require('tests.helper'):setup()

helper:add_cases('visual_selection', {
    ['markup'] = function() helper:test_snip('ll', '$a+b+c$') end,
    ['markup_multiline'] = function() helper:test_snip('tem', '#theorem[\n  a+b+c\n]') end,
    ['precedence'] = function() helper:test_snip_math('(a)ht', '(a)hat(a+b+c)') end,
    ['precedence2'] = function() helper:test_snip_math('aht', 'ahat(a+b+c)') end,
    ['nested'] = function()
        helper:set_buffer('$root(\\C)$')
        helper:test_snip('ht', '$root(hat(a+b+c))$')
    end,
}, {
    setup = function() helper:store_selection('a+b+c') end,
})

helper:add_cases('visual_postfix', {
    ['postfix'] = function() helper:test_snip_math('aht', 'hat(a)') end,
    ['long'] = function() helper:test_snip_math('alphaht', 'hat(alpha)') end,
    ['nested'] = function() helper:test_snip_math('artht', 'hat(sqrt(a))') end,
    ['brackets'] = function() helper:test_snip_math('(a)ht', 'hat(a)') end,
    ['precedence'] = function() helper:test_snip_math('a_alphaht', 'a_hat(alpha)') end,
    ['precedence2'] = function() helper:test_snip_math('a_b_alphaht', 'a_b_hat(alpha)') end,
})

helper:add_cases('visual_normal', {
    ['normal'] = function() helper:test_snip_math('hta\\j b', 'hat(a) b') end,
    ['long'] = function() helper:test_snip_math('ht;a\\j b', 'hat(alpha) b') end,
    ['nested'] = function()
        helper:set_buffer('$root(\\C)$')
        helper:test_snip('rta\\j b', '$root(sqrt(a) b)$')
    end,
})

return helper.test_set
