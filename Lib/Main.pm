package Main;

use strict;
use  warnings; 
use CGI;
use JSON;
use Template;
use debug::utils;

sub new {
    my $class = shift;
    debug::utils->Log();

    my %params = @_;

    my $self = {};
    bless $self, $class;

    $self->{cgi} = new CGI;
    $self->{PageNumber} = 0;

    $self->{template} = 
        Template->new({INCLUDE_PATH => [ '/Library/WebServer/Templates',
                                       ],
                      },
                     );

    return $self;
}

sub run {
    my $self = shift;
    debug::utils->Log();

    my $q = $self->{cgi};

    if ($q->param()) {
        if ($q->param('name')) {
            $self->query($q->param('name'));
        }
        elsif ($q->param('image')) {
            $self->image($q->param('image'));
        }
    }
    else {
        $self->main();
    }
}

sub main {
    my $self = shift;
    debug::utils->Log();

    my $q = $self->{cgi};
    my $tt = $self->{template};

    #  define data 
    my  $data = {
        title => 'Fun With Templates',
        copyright => '&copy; 2002  Andy Wardley', 
        weblinks   => [
            {
                url    => 'http://perl.apache.org/',
                title => 'Apache/mod_perl',
            },
            {
                url => 'http://tt2.org/',
                title => 'template Toolkit',
            },
        ]
    };

    my $output;
    $tt->process('main.tt', $data, \$output) || die $tt->error();
    print $q->header('text/html'), 
          $output;
}

sub query {
    my $self = shift;
    my $name = shift;
    debug::utils->Log();

    my $q = $self->{cgi};
    my $tt = $self->{template};

    my $data = {PageNumber => $self->{PageNumber}+1};
    my $output;
    debug::utils->Log($data);
    $tt->process("$name.tt", $data, \$output);
    $self->send_success_json({text => $output});
}

sub image {
    my $self = shift;
    my $name = shift;
    debug::utils->Log();

    my $q = $self->{cgi};
    my $tt = $self->{template};

    my $data = {PageNumber => $self->{PageNumber}+1};
    my $output;
    debug::utils->Log($data);
    $tt->process("$name.tt", $data, \$output);
    $self->send_success_json({text => $output});
}

sub send_success_json {
    my $self = shift;
    my $additional_properties = shift;
    debug::utils->Log($additional_properties);

    $self->send_json(1,'',$additional_properties);
}

sub send_json {
    my $self = shift;
    my $request_successfully_completed = shift;
    my $error_message= shift;
    my $additional_properties = shift;
    debug::utils->Log();

    my $q = $self->{cgi};
    my %response = ('success' => $request_successfully_completed,
                    'message' => $error_message
                   );
    if (ref($additional_properties) eq 'HASH') {
      for (keys %$additional_properties) {
        $response{$_} = $additional_properties->{$_};
      }
    }
    print $q->header('text/json');
    print encode_json(\%response);
    exit;
}

1;
