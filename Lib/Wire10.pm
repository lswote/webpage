package::Wire10;

use strict;
use Net::Wire10;

sub wire_connect {
    my $wire = Net::Wire10->new(
        host     => 'localhost',
        user     => 'bhammond',
        password => 'bhammond',
        database => 'website'
    );
    $wire->connect;

    return $wire;
}

1;
