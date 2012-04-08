#!perl -w
use strict;
use Test::More;

use Groonga::QueryBuilder;

like Groonga::QueryBuilder::_escape_value('ho" fuga:@"hoge"'),  qr/^"(?:[^"]|\\")+"$/, 'escape ok';

is+Groonga::QueryBuilder->build(
    bar => 'ho" fuga:@"hoge"',
) => 'bar:"ho\\" fuga:@\\"hoge\\""', 'query escape ok';

is+Groonga::QueryBuilder->build(
    bar => 'bar',
) => 'bar:"bar"', 'simple query';

is+Groonga::QueryBuilder->build(
    bar => 'bar',
    foo => 'foo',
) => 'bar:"bar" + foo:"foo"', 'dual condition query';

is+Groonga::QueryBuilder->build(
    foo => [
        0,
        ['+' => {'<=' => -1}, {'>=' => -2}],
        ['+' => {'>'  =>  1}, {'<'  =>  2}]
    ],
) => '(foo:"0" OR (foo:<="-1" + foo:>="-2") OR (foo:>"1" + foo:<"2"))', 'deep query';

subtest 'multi query' => sub {
    is+Groonga::QueryBuilder->build(
        foo => ['foo', 'bar'],
    ) => '(foo:"foo" OR foo:"bar")', 'OR query';

    is+Groonga::QueryBuilder->build(
        foo => ['+' => 'foo', 'bar'],
    ) => '(foo:"foo" + foo:"bar")', '+ query';

    is+Groonga::QueryBuilder->build(
        foo => ['-' => 'foo', 'bar'],
    ) => '(foo:"foo" - foo:"bar")', '- query';
};

subtest 'specified query' => sub {
    is+Groonga::QueryBuilder->build(
            foo => {-match => 'foo' },
    ) => 'foo:@"foo"', '-match query';

    is+Groonga::QueryBuilder->build(
        foo => {'>' => 'foo' },
    ) => 'foo:>"foo"', '> query';

    is+Groonga::QueryBuilder->build(
        foo => {'>=' => 'foo' },
    ) => 'foo:>="foo"', '>= query';

    is+Groonga::QueryBuilder->build(
        foo => {'<' => 'foo' },
    ) => 'foo:<"foo"', '< query';

    is+Groonga::QueryBuilder->build(
        foo => {'<=' => 'foo' },
    ) => 'foo:<="foo"', '<= query';

    is+Groonga::QueryBuilder->build(
        foo => {'!=' => 'foo' },
    ) => 'foo:!"foo"', '!= query';
};

done_testing;
