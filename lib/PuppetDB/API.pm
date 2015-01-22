package PuppetDB::API;

use 5.010000;
use strict;
use warnings;
use Carp qw(cluck croak carp);
use Data::Dumper;
use LWP::UserAgent;
use Moo;
use JSON::XS;
require Exporter;


our $VERSION = '0.01';


has url => (
    is => 'ro',
);

has ca => (
    is => 'ro',
    default => sub {return}
);

has client_cert => (
    is => 'ro',
    default => sub {return}
);

has client_key => (
    is => 'ro',
    default => sub {return},
);

has timeout => (
    is => 'ro',
    default => sub {return 120},
);



sub BUILD {
    my $self = shift;
    my $tls;
    my $ua = LWP::UserAgent->new();
    $ua->timeout($self->timeout);

    if ($self->url =~ /^https/) {
        if (!$self->client_cert || !$self->client_key) {
            croak("need client cert + key in https mode");
        }
        $ua->ssl_opts(
            'SSL_cert_file' => $self->client_cert,
            'SSL_key_file' => $self->client_key,
            'SSL_verify_mode' => 'SSL_VERIFY_NONE', # FIXME
        );
    }
    $self->{'ua'} = $ua;
    return $self;
}

sub get {
    my $self = shift;
    my $path = shift;
    my $resp = $self->{'ua'}->get($self->url . $path);

    if ($resp->is_success()) {
        my $out;
        eval {
            $out = decode_json($resp->content)
        };
        return $out;
    } else {
        print Dumper $resp;
    }       
    return;
}




1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Module::Example - Perl extension for blah blah blah

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
