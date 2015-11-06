#!/usr/bin/perl

BEGIN {
    use lib "/usr/local/cad-lib";
}

use strict;
use Common qw (
    dumpVar
    trimString
);
use CGI qw (:standard);
use CGI::Carp qw(fatalsToBrowser);
use LWP::UserAgent;
use JSON;

my $APIURL = "http://bruce-dancer.haneys.net";

my $info = new CGI;

# This cookie expires a browser close
my $session_id = $info->cookie('SESSION_ID');

if (defined($session_id)) {
	my $url = sprintf("%s/logout/%s", $APIURL,$session_id);

	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new(GET => $url);

	my $res = $ua->request($req);

	# This is a hash ref
	my $result = from_json($res->content);

	# Expire the cookie
	my $sess_cookie = $info->cookie(
                           -name => 'SESSION_ID',
                           -value => $result->{'SESSION_ID'},
                           -expires => '-1000h'
                           );
	print $info->header(-cookie => [$sess_cookie]);
} else {
	print $info->header();
}

print "You have been logged out.";
