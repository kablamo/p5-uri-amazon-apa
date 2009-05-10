package URI::Amazon::APA;
use warnings;
use strict;
our $VERSION = sprintf "%d.%02d", q$Revision: 0.2 $ =~ /(\d+)/g;
use Carp;
use POSIX qw(strftime);
use Digest::SHA qw(hmac_sha256_base64);
use URI::Escape;
use base 'URI::http';

sub new{
    my $class = shift;
    my $self  = URI->new(@_);
    ref $self eq 'URI::http' or carp "must be http";
    bless $self, $class;
}

sub sign {
    my $self  = shift;
    my (%arg) = @_;
    my %eq = map { split /=/, $_ } split /&/, $self->query();
    my %q = map { $_ => uri_unescape( $eq{$_} ) } keys %eq;
    $q{AWSAccessKeyId} = $arg{key};
    # 2009-01-01T12:00:00Z
    $q{Timestamp} ||= strftime( "%Y-%m-%dT%TZ", gmtime() );
    $q{Version}   ||= '2009-01-01';
    my $sq = join '&', map { $_ . '=' . uri_escape( $q{$_} ) } sort keys %q;
    my $tosign = join "\n", 'GET', $self->host, $self->path, $sq;
    my $signature = hmac_sha256_base64($tosign, $arg{secret});
    $signature .= '=' while length($signature) % 4; # padding required
    $q{Signature} = $signature;
    $self->query_form( \%q );
    $self;
}

sub signature {
    my $self  = shift;
    my (%arg) = @_;
    my %eq = map { split /=/, $_ } split /&/, $self->query();
    my %q = map { $_ => uri_unescape( $eq{$_} ) } keys %eq;
    $q{Signature};
}

if ( $0 eq __FILE__ ) {
}

1; # End of URI::Amazon::APA

=head1 NAME

URI::Amazon::APA - URI to access Amazon Product Advertising API


=head1 VERSION

$Id$

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use URI::Amazon::APA;

    my $foo = URI::Amazon::APA->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=head1 AUTHOR

Dan Kogai, C<< <dankogai at dan.co.jp> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-uri-amazon-apa at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=URI-Amazon-APA>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc URI::Amazon::APA


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=URI-Amazon-APA>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/URI-Amazon-APA>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/URI-Amazon-APA>

=item * Search CPAN

L<http://search.cpan.org/dist/URI-Amazon-APA/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Kogai, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
