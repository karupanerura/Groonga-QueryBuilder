package Groonga::QueryBuilder;
use 5.010_000;
use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

use Carp;
use Data::Validator;

sub build {
    my $class = shift;
    my $args  = (@_ == 1 and ref($_[0]) eq 'HASH') ? +shift : +{ @_ };

    my @queries;
    foreach my $key (sort keys %$args) {
        push @queries => $class->_build($key => $args->{$key});
    }

    return join(' + ', @queries);
}

sub _build {
    state $rule = Data::Validator->new(
        column    => 'Str',
        cond      => 'Defined',
    )->with(qw/Method StrictSequenced/);
    my($self, $args) = $rule->validate(@_);

    my $column = $args->{column};
    my $cond   = $args->{cond};
    my $query  = '';
    if (ref $cond) {
        if (ref $cond eq 'ARRAY') {
            my @vals = @$cond;
            my $join = ($vals[0] eq '+' or $vals[0] eq '-') ?
                shift(@vals):
                'OR';

            foreach my $val (@vals) {
                $query .= " $join " if $query;
                $query .= $self->_build($column => $val);
            }
            $query = "(${query})";
        }
        elsif (ref $cond eq 'HASH') {
            state $cond_rule_hash = +{
                '<'      => ':<',
                '>'      => ':>',
                '!='     => ':!',
                '<='     => ':<=',
                '>='     => ':>=',
                '-match' => ':@'
            };
            foreach my $cond_rule (keys %$cond) {
                unless (exists $cond_rule_hash->{$cond_rule}) {
                    croak("unknown cond = ref($cond_rule)");
                }
                my $rule = $cond_rule_hash->{$cond_rule};
                my $val  = _escape_value($cond->{$cond_rule});
                $query = "${column}${rule}${val}";
                last;
            }
        }
        else {
            croak("unknown cond = ref($cond)");
        }
    }
    else {
        $cond  = _escape_value($cond);
        $query = "${column}:${cond}";
    }

    return $query;
}

sub _escape_value {
    state $rule = Data::Validator->new(
        val  => 'Str',
    )->with(qw/StrictSequenced/);
    my $val = $rule->validate(@_)->{val};
    $val =~ s/"/\\"/g;
    return qq{"${val}"};
}

1;
__END__

=head1 NAME

Groonga::QueryBuilder - Groonga's query builder.

=head1 VERSION

This document describes Groonga::QueryBuilder version 0.01.

=head1 SYNOPSIS

    use Groonga::QueryBuilder;

    my $query = Groonga::QueryBuilder->build(
        foo => 'hoge',
        bar => {-match => 'fuga'},## Full text search
    );

    say $query; # foo:"hoge" + bar:@"fuga"

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Methods

=head3 C<< build >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Kenta Sato. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
