package WriteOff::Schema::ResultSet::Scoreboard;

use strict;
use base 'WriteOff::Schema::ResultSet';

my @medals = qw/gold silver bronze/;

sub tally_storys {
	my( $self, $storys_rs ) = @_;
	
	my @storys = $storys_rs->tally_order;
	my $n = $storys_rs->count;
	my %tally; 
	
	for( my $i = 0; $i < $n; $i++ ) {
		my $storage = $self->find_or_create($storys[$i]->author);
		my $author = $storage->competitor;
		
		# Deal with tiebreakers
		my($upper, $lower) = ($i, $i);
		$upper++ while $upper < $#storys &&
			$storys[$i]->public_score  == $storys[$upper+1]->public_score &&
			$storys[$i]->private_score == $storys[$upper+1]->private_score;
		$lower-- while $lower > 0 &&
			$storys[$i]->public_score  == $storys[$lower-1]->public_score &&
			$storys[$i]->private_score == $storys[$lower-1]->private_score;
		
		$tally{$author} //= { score => $storage->score };
		$tally{$author}{score} += $n - ($upper + $lower) - 1;
		
		if( $lower <= $#medals ) {
			$tally{$author}{awards} //= [];
			push @{ $tally{$author}{awards} }, $medals[$lower];
		}
	}
	
	while( my($author, $data) = each %tally ) {
		my $row = $self->find($author);
		$row->update({
			score  => $data->{score} > 0 ? $data->{score} : 0,
			awards => [ $row->awards, @{ $data->{awards} // ['ribbon'] } ],
		});
	}
}

sub ordered {
	return shift->search(undef, { order_by => [
		{ -desc => 'score' },
		{ -asc  => 'competitor' },
	]});
}

1;

__END__

=pod

=head1 NAME

WriteOff::Schema::ResultSet::Scoreboard - Application scoreboard.

=head1 SYNOPSIS

=head2 Scores

Both tally methods tally scores by the formula `n - 2p + 1`, where `n` is the
number of items in the tally and `p` is the position of the item.

(The actual equation used is `n - 2i - 1`, where `i` is the index of the item.
The two are equivalent since `p = i + 1`, so `n - 2p + 1 = n - 2(i + 1) + 1 =
n - 2i - 1`.)

Items with tied sort rank are given a position equal to the average of their
indices, e.g., if three items are tied for 2nd place, they will each get a score
where `p = avg(1, 2, 3) = 2`. This maintains the system as zero-sum.

=head2 Awards

Positions 1, 2, and 3 get gold, silver, and bronze medals respectively. In the
case of ties, the award given is that which goes to the highest position in the 
tied group (i.e., five items all tied for 3rd will each get a bronze medal).

All items with no other award are given a participation ribbon. If a competitor
appears more than once in a given set, they are only given one ribbon.

=head1 METHODS

=head2 tally_storys

Tallies scores from a L<WriteOff::Schema::ResultSet::Story> object.

=head2 tally_images

Tallies scores from a L<WriteOff::Schema::ResultSet::Image> object.

=cut