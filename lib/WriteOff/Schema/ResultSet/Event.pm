package WriteOff::Schema::ResultSet::Event;

use strict;
use base 'WriteOff::Schema::ResultSet';

sub active {	
	my $self = shift;
	return $self->search(
		{ end => 
			{ '>' => 
				$self->format_datetime( $self->now_dt->subtract( days => 1 ) ) 
			} 
		},
		{ order_by => { -asc => 'end' } },
	);
}

sub old {
	my $self = shift;
	return $self->search(
		{ end => 
			{ '<' => 
				$self->format_datetime( $self->now_dt->subtract( days => 1 ) ) 
			} 
		},
		{ order_by => { -desc => 'end' } },
	);
}

sub finished {
	my $self = shift;
	return $self->search(
		{ end => { '<' => $self->now } },
		{ order_by => { -asc => 'end' } }
	);
}

sub sanitized_search {
    my ( $self, $search ) = @_;
    return $self->search($search,
        {
            'select'   =>  ['id','prompt',\'IFNULL(blurb,"None")','wc_min','wc_max',
                            \'CASE rule_set WHEN 1 THEN "T" WHEN 2 THEN "M" ELSE "E" END', \'IFNULL(custom_rules,"None")',
                            'start','prompt_voting','prompt_voting',\'IFNULL(art,fic)',
                            \'IFNULL(art,0)',\'IFNULL(art_end,0)','fic','fic_end',\'IFNULL(prelim,0)',
                            'public',\'IFNULL(private,0)', 'end', 'created' ],
            'as'        =>  ['Event.ID', 'Info.Initial Prompt', 'Info.Blurb', 'Word Count.Min', 'Word Count.Max', 
                            'Rules.Content Level', 'Rules.Custom',
                            'Prompt Submission.Start','Prompt Submission.End', 'Prompt Voting.Start', 'Prompt Voting.End',
                            'Art.Start', 'Art.End', 'Fic.Start', 'Fic.End', 
                            'Voting.Preliminaries Start','Voting.Main Start', 'Voting.Finals Start', 'Voting.Ends', 'Event.Created at']
        },
    );
}

1;
