use utf8;
package WriteOff::Schema::Result::User;

use strict;
use warnings;
use base "WriteOff::Schema::Result";

__PACKAGE__->load_components('PassphraseColumn');

__PACKAGE__->table("users");

__PACKAGE__->add_columns(
	"id",
	{ data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
	"username",
	{ data_type => "text", is_nullable => 0 },
	"password", {
		data_type        => "text",
		is_nullable      => 0,
		passphrase       => 'rfc2307',
		passphrase_class => 'SaltedDigest',
		passphrase_args  => {
			algorithm   => 'SHA-1',
			salt_random => 20,
		},
		passphrase_check_method => 'check_password',
	},
	"email",
	{ data_type => "text", is_nullable => 1 },
	"email_new",
	{ data_type => "text", is_nullable => 1 },
	"timezone",
	{ data_type => "text", default_value => "UTC", is_nullable => 1 },
	"ip",
	{ data_type => "text", is_nullable => 1 },
	"verified",
	{ data_type => "integer", default_value => 0, is_nullable => 0 },
	"mailme",
	{ data_type => "integer", default_value => 0, is_nullable => 0 },
	"last_mailed_at",
	{ data_type => "timestamp", is_nullable => 1 },
	"token",
	{ data_type => "text", is_nullable => 1 },
	"created",
	{ data_type => "timestamp", is_nullable => 1 },
	"updated",
	{ data_type => "timestamp", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint("email_unique", ["email"]);

__PACKAGE__->add_unique_constraint("username_unique", ["username"]);

__PACKAGE__->has_many(
	"artists",
	"WriteOff::Schema::Result::Artist",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"images",
	"WriteOff::Schema::Result::Image",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"news",
	"WriteOff::Schema::Result::News",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"prompts",
	"WriteOff::Schema::Result::Prompt",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"storys",
	"WriteOff::Schema::Result::Story",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"user_events",
	"WriteOff::Schema::Result::UserEvent",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"user_roles",
	"WriteOff::Schema::Result::UserRole",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
	"vote_records",
	"WriteOff::Schema::Result::VoteRecord",
	{ "foreign.user_id" => "self.id" },
	{ cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->many_to_many("roles", "user_roles", "role");

__PACKAGE__->mk_group_accessors(
	column => 'role',
	column => 'prompt_skill',
	column => 'hugbox_score',
);

sub name {
	return shift->username;
}

sub username_and_email {
	my $self = shift;

	return sprintf "%s <%s>", $self->username, $self->email;
}

sub last_author {
	my $self = shift;
	my $last_story = $self->storys->order_by({ -desc => 'updated' })->first;
	return $last_story ? $last_story->author : undef;
}

sub last_artist {
	my $self = shift;
	my $last_image = $self->images->order_by({ -desc => 'updated' })->first;
	return $last_image ? $last_image->artist : undef;
}

sub is_admin {
	my $self = shift;

	return $self->roles->search({ role => 'admin' })->count;
}

sub new_token {
	my $self = shift;

	my $token = Digest->new('MD5')
		->add( join("", time, $self->password, rand(10000), $$) )
		->hexdigest;

	$self->update({ token => $token });

	return $token;
}

sub new_password {
	my $self = shift;

	my $pass = substr Digest->new('MD5')->add( rand, $$ )->hexdigest, 0, 5;

	$self->update({ password => $pass });

	return $pass;
}

sub has_been_mailed_recently {
	my $self = shift;

	return $self->check_datetimes_ascend
	( DateTime->now->subtract( hours => 1 ), $self->last_mailed_at );
}

sub check_datetimes_ascend {
	my $row = shift;

	return 1 if join('', @_) eq join('', sort @_);
	0;
}

1;
