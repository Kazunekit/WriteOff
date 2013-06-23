package WriteOff::View::ApiJSON;
use Moose;
use namespace::autoclean 
extends 'Catalyst::View';
__PACKAGE__->mk_accessors(qw( expose_stash pretty  ));

sub process {
    my($self, $c) = @_;
    my $cond = sub { 1 };
    my $single_key;
    if (my $expose = $self->expose_stash) {
        if (ref($expose) eq 'Regexp') {
            $cond = sub { $_[0] =~ $expose };
        } elsif (ref($expose) eq 'ARRAY') {
            my %match = map { $_ => 1 } @$expose;
            $cond = sub { $match{$_[0]} };
        } elsif (!ref($expose)) {
            $single_key = $expose;
        } else {
            $c->log->warn("expose_stash should be an array referernce or Regexp object.");
        }
    }
    my $pretty = $self->pretty;

    my $data;
    if ($single_key) {
        $data = $c->stash->{$single_key};
    } else {
        $data = { map { $cond->($_) ? ($_ => $c->stash->{$_}) : () }
                  keys %{$c->stash} };
    }
    use JSON::XS;
    my $json = JSON::XS->new->utf8->pretty($pretty);
    my $output;

    eval {
        $output = $json->encode($data);
    };
    return $@ if $@;

    $c->res->output($output);
    return 1;  # important

}

=head1 NAME

WriteOff::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<WriteOff>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

Cameron,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
