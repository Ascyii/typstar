local helper = require('tests.helper'):setup()

helper:add_cases('markup', {
    ['emph'] = function() helper:test_snip('BLDbold\\j ITLitalic', '*bold* _italic_') end,
    ['selection'] = function()
        helper:store_selection('hello world')
        helper:test_snip('HIG', '#highlight[hello world]')
    end,
    ['logic'] = function() helper:test_snip('IMPIFF', '$==>$ $<==>$ ') end,
    ['math'] = function() helper:test_snip('kkAtp\\j a', '$A^top $ a') end,
    ['blockmath'] = function() helper:test_snip('dmpi>e\\j a', '$\n  pi>e\n$ a') end,
    ['blockmath2'] = function() helper:test_snip('abc dmpi\\j a', 'abc\n$\n  pi\n$ a') end,
    ['blockmath3'] = function() helper:test_snip('  dmpi\\j a', '  $\n    pi\n  $ a') end,
    ['blockmath4'] = function() helper:test_snip('- abc dmpi\\j a', '- abc \n  $\n    pi\n  $ a') end,
})

return helper.test_set
