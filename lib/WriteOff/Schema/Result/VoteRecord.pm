use utf8;
package WriteOff::Schema::Result::VoteRecord;

use strict;
use warnings;
use base "WriteOff::Schema::Result";

__PACKAGE__->table("vote_records");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"event_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
	"user_id",
	{ data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
	"ip",
	{ data_type => "text", is_nullable => 1 },
	"round",
	{ data_type => "text", is_nullable => 0 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
	"type",
	{ data_type => "text", default_value => "unknown", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
	"event",
	"WriteOff::Schema::Result::Event",
	{ id => "event_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
	"user",
	"WriteOff::Schema::Result::User",
	{ id => "user_id" },
	{
		is_deferrable => 1,
		join_type     => "LEFT",
		on_delete     => "CASCADE",
		on_update     => "CASCADE",
	},
);

__PACKAGE__->has_many(
	"votes",
	"WriteOff::Schema::Result::Vote",
	{ "foreign.record_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->mk_group_accessors(
	column => 'variance',
	column => 'mean',
);

sub now_dt {
	return shift->result_source->resultset->now_dt;
}

sub is_filled {
	my $self = shift;

	return 1 if defined $self->votes->get_column('value')->next;
	0;
}

sub is_empty {
	my $self = shift;

	return 1 if $self->votes->count == 0;
	0;
}

sub is_unfilled {
	my $self = shift;

	return 0 if $self->is_filled;
	return 0 if $self->is_empty;
	1;
}

sub is_fillable {
	my $self = shift;
	my $event = $self->event;

	return 1 if $self->round eq 'prelim'  && $event->prelim_votes_allowed;
	return 1 if $self->round eq 'private' && $event->private_votes_allowed;
	0;
}


sub is_publicly_viewable {
	my $self = shift;

	return $self->round eq 'private' && $self->event->end <= $self->now_dt;
}

sub stdev {
	my $self = shift;

	return $self->{__stdev} = #eval { sqrt $self->variance } //
		$self->votes->stdev;
}

sub avg {
	my $self = shift;

	return $self->{__avg} = $self->values->func('avg');
}

sub values {
	my $self = shift;

	return $self->votes->get_column('value');
}

sub range {
	my $self = shift;

	return $self->{__range} //=
		$self->round eq 'public' ?
		[ 0 .. 10 ] :
		[ sort { $a <=> $b } $self->values->all ];
}

1;
