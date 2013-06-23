package WriteOff::Controller::Api;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
 
sub api : Chained('/') :PathPart('api') :CaptureArgs(0) {
    my ( $self, $c ) = @_;
 
    if (!exists($c->stash->{'api_params'})) {
        $c->stash->{'api_params'} = $c->req->params;
        if (!exists($c->stash->{'api_params'}{'output'})) {
            $c->stash->{'api_params'}{'output'} = 'json';
        }
    } elsif (!exists($c->stash->{'api_params'}{'output'})) {
        $c->stash->{'api_params'}{'output'} = 'json';
    }
    ## This sets the default response as a failure. 
    $c->stash->{apiresponse} = { 'processed' => 0, 'status' => 'failed' };
 
}
 
sub gettime : Chained('api') :PathPart('gettime') :Args(0) {
   my ($self, $c) = @_;
 
   # do something interesting.
   my $server_time = scalar localtime;
 
   $c->stash->{apiresponse} = {
       'processed' => 1,
       'status' => 'OK',
       'server_time' => $server_time,
       'params' => $c->stash->{'api_params'},
   };
 
}

sub events : Chained('api') :PathPart('events') :Args(0) {
    my ($self, $c) = @_;

    my $events = $c->model('DB::Event')->sanitized_search()->active;
    $events->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my @data = $events->all;
    $c->stash->{'apiresponse'} = {
        'Event Count' => scalar @data,
        'Events' => \@data, 
    };
}
 
sub event : Chained('api') :PathPart('event') :Args(1) {
    my ($self, $c, $arg) = @_;

    my $event = $c->model('DB::Event')->sanitized_search({'id'=>$arg});
    $event->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $data = $event->first;
#    use Data::Dumper; print Dumper($data);
    $c->stash->{'apiresponse'} = $data;
}

sub event : Chained('api') :PathPart('story') :Args(1) {
    my ($self, $c, $arg) = @_;

    my $event = $c->model('DB::Story')->sanitized_search({'me.id'=>$arg});
    $event->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $data = $event->first;
#    use Data::Dumper; print Dumper($data);
    $c->stash->{'apiresponse'} = $data;
}

sub end : Private {
    my ( $self, $c ) = @_;
 
    if ($c->stash->{'api_params'}{'output'} eq 'xml')
    {
        $c->detach( $c->view('XML') );
    } else {
        $c->detach( $c->view('ApiJSON') );
    }
}

=head1 AUTHOR

Jaroslav Bisikirski E<lt>kazunekit@gmail.comE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
