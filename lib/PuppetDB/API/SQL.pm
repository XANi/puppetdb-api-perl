package PuppetDB::API::SQL;

use 5.010000;
use strict;
use warnings;
use Carp qw(cluck croak carp);
use Data::Dumper;

use Moo;
use SQL::Statement;

has parser => (
    'is' => 'ro',
    default => sub {SQL::Parser->new()},
);




sub parse_query() {
    my $self = shift;
    my $query = shift;
    # http://search.cpan.org/~rehsack/SQL-Statement-1.405/lib/SQL/Statement/Structure.pod
    my $q = SQL::Statement->new($query, $self->parser);
    my @tables = $q->tables();
    if (@tables > 1 ) {croak('only queries from one "table" are supported')}
    my $table_name = $tables[0]->name;
    if ($table_name !~ /^(nodes|facts|catalogs|resources|events)$/) {
        croak("Table $table_name not supported");
    }
    my $where = $q->where_hash;
    my $pdb_query = {
        endpoint => $table_name,
        columns => $q->column_defs,
        limit => $q->limit,
        offset => $q->offset,
        query  => $self->_parse_where($where,$table_name),
        raw_q => $where,
    };
    return $pdb_query
}

sub _parse_where {
    my $self = shift;
    my $hash = shift;

    if (!defined($hash->{'arg1'})) {
        # exception, parser does not accept 'value' as column name
        if ($hash->{'type'} eq 'column'
                && $hash->{'value'} eq 'fact_value'
            ) {
            return 'value'
        }
        if ($hash->{'type'} eq 'column'
                && $hash->{'value'} eq 'fact_name'
            ) {
            return 'name'
        }
        return $hash->{'value'}
    }
    my $op = lc($hash->{'op'});
    if ($op eq 'like') {
        if ($hash->{'neg'}) {
            die('not like not supported yet')
        }
        else {
            $op = '~'
        }
    }
    if (defined($hash->{'arg1'}{'type'}) && defined($hash->{'arg2'}{'type'})) {
        if ($hash->{'arg1'}{'type'} ne 'column'
                && $hash->{'arg2'}{'type'} eq 'column' ) {
            my $a = $hash->{'arg2'};
            $hash->{'arg2'} = $hash->{'arg1'};
            $hash->{'arg1'} = $a;
        }
        if ($hash->{'arg1'}{'type'} eq $hash->{'arg2'}{'type'}) {
            my $d = Dumper $hash;
            croak ("one of arguments of comparision should be column, other value quoted in ' '" . $d);
        }
    }


    return [
        $op,
        $self->_parse_where($hash->{'arg1'}),
        $self->_parse_where($hash->{'arg2'})
    ];
}




1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

PuppetDB::API::SQL - SQLish query generator for puppetdb

=head1 SYNOPSIS

  use Module::Example;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Module::Example, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

xani, E<lt>xani@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by xani

This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself, either Perl version 5.12.3 or,
  at your option, any later version of Perl 5 you may have available.


  =cut
