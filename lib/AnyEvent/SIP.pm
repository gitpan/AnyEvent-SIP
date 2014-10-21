use strict;
use warnings;
package AnyEvent::SIP;
{
  $AnyEvent::SIP::VERSION = '0.001';
}
# ABSTRACT: Fusing together AnyEvent and Net::SIP

use Net::SIP::Dispatcher::AnyEvent;
use Net::SIP::Dispatcher::Eventloop;

{
    no warnings qw<redefine once>;
    *Net::SIP::Dispatcher::Eventloop::new = sub {
        Net::SIP::Dispatcher::AnyEvent->new
    };
}

1;

__END__

=pod

=head1 NAME

AnyEvent::SIP - Fusing together AnyEvent and Net::SIP

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    # regular Net::SIP syntax
    use AnyEvent::SIP;
    use Net::SIP::Simple;

    my $stopvar;
    my $ua   = Net::SIP::Simple->new(...);
    my $call = $uac->invite(
        'you.uas@example.com',
        cb_final => sub { $stopvar++ },
    );

    # wait for $stopvar, 5 second timeout
    $ua->loop( 5, \$stopvar );

    # AnyEvent-style
    use AnyEvent::SIP;
    use Net::SIP::Simple;

    my $cv   = AE::cv;
    my $ua   = Net::SIP::Simple->new(...);
    my $call = $uac->invite(
        'you.uas@example.com',
        cb_final => sub { $cv->send },
    );

    $cv->recv;

=head1 DESCRIPTION

This module allows you to use L<AnyEvent> as the event loop (and thus any
other supported event loop) for L<Net::SIP>.

L<Net::SIP::Simple> allows you to define the event loop. You can either define
it using L<Net::SIP::Dispatcher::AnyEvent> manually or you can simply use
L<AnyEvent::SIP> which will automatically set it for you.

    # doing it automatically and globally
    use AnyEvent::SIP;
    use Net::SIP::Simple;

    my $cv = AE::cv;
    my $ua = Net::SIP::Simple->new(...);
    $ua->register( cb_final => sub { $cv->send } );
    $cv->recv;

    # defining it for a specific object
    use Net::SIP::Simple;
    use Net::SIP::Dispatcher::AnyEvent;

    my $cv = AE::cv;
    my $ua = Net::SIP::Simple->(
        ...
        loop => Net::SIP::Dispatcher::AnyEvent->new,
    );

    $ua->register;
    $cv->recv;

You can also call L<Net::SIP>'s C<loop> method in order to keep it as close as
possible to the original syntax. This will internally use L<AnyEvent>, whether
you're using L<AnyEvent::SIP> globally or L<Net::SIP::Dispatcher::AnyEvent>
locally.

    use AnyEvent::SIP;
    use Net::SIP::Simple;

    my $stopvar;
    my $ua = Net::SIP::Simple->new(...);
    $ua->register( cb_final => sub { $stopvar++ } );

    # call Net::SIP's event loop runner,
    # which calls AnyEvent's instead
    $ua->loop( 1, \$stopvar );

=head1 WARNING

L<Net::SIP> requires dispatchers (event loops) to check their stopvars
(condition variables) every single iteration of the loop. In my opinion, it's
a wasteful and heavy operation. When it comes to loops like L<EV>, they run
a B<lot> of cycles, and it's probably not very effecient. Take that under
advisement.

I would happily accept any suggestions on how to improve this. Meanwhile,
we're using L<AnyEvent::AggressiveIdle>.

=head1 AUTHOR

Sawyer X <xsawyerx@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Sawyer X.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
