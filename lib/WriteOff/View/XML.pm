package WriteOff::View::XML;

use Moose;
use namespace::autoclean 
extends 'Catalyst::View';
__PACKAGE__->mk_accessors(qw( expose_stash no_attr root_name xmldecl ));


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
    my $no_attr = $self->no_attr;
    my $root_name = $self->root_name || 'xml';
    my $xmldecl = $self->xmldecl;

    my $data;
    if ($single_key) {
        $data = $c->stash->{$single_key};
    } else {
        $data = { map { $cond->($_) ? ($_ => $c->stash->{$_}) : () }
                  keys %{$c->stash} };
    }
    use XML::Simple;
    my $xs = XML::Simple->new(NoAttr => $no_attr, RootName => $root_name, XMLDecl => $xmldecl);
    my $output;

    eval {
        $output = $xs->XMLout($data);
    };
    return $@ if $@;

    $c->res->output($output);
    return 1;  # important

}


1;
__END__

=head1 NAME

Based completely on
Catalyst::View::XML::Simple - XML view for your data

=head1 DESCRIPTION

Catalyst::View::XML::Simple is a Catalyst View handler that returns stash
data in XML format using XML::Simple. 

This returns everything in a prettier format
And allows customization

=head1 AUTHOR

Jaroslav Bisikirski E<lt>kazunekit@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 Thanks

Lindolfo 'Lorn' Rodrigues  E<lt>lorn at cpan.orgE<gt>

=cut

