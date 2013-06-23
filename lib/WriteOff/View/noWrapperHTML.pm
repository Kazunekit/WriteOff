package WriteOff::View::noWrapperHTML;
use utf8;
use Moose;

extends 'WriteOff::View::HTML';

__PACKAGE__->config(
    WRAPPER            => '',
);

1;
