#!/usr/bin/perl

BEGIN {
    use lib "/usr/local/cad-lib";
    use lib "/var/www/icms4/lib";
}

use strict;
use Common qw (
    doTemplate
    trimString
);
use CGI qw (:standard);
use CGI::Carp qw(fatalsToBrowser);
use LWP::UserAgent;
use JSON;
use ICMS::Config qw (
    $APIURL
    $TEMPLATEDIR
);

my $info = new CGI;

my %params = $info->Vars;

my %data = ();
my @url_parts = split(/[?&]/, $ENV{REQUEST_URI});
if ($#url_parts > 0) {
   for my $pair (@url_parts) {
       my @fields = split ('=', $pair);
       if (($#fields > 0) && ($fields[0] eq 'referrer')) {
           $data{url} = $fields[1];
           last;
       }
   }
}
if (!defined($data{url}) && defined($params{url})) {
   $data{url} = $params{url};
}

if ((!defined($params{'username'})) || (!defined($params{'password'}))) {
	print $info->header();
	doTemplate(\%data,$TEMPLATEDIR,"login.tt",1);
    exit;
}

my $username = trimString($params{'username'});
my $password = trimString($params{'password'});

my $url = sprintf("%s/login/%s/%s", $APIURL,$username,$password);

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $url);

my $res = $ua->request($req);

# This is a hash ref
my $result = from_json($res->content);

if (!defined($result->{'SUCCESS'})) {
	# Failure
	print $info->header();
	doTemplate(\%data,$TEMPLATEDIR,"login.tt",1);
    exit;
}

my $sess_cookie = $info->cookie(
                           -name => 'SESSION_ID',
                           -value => $result->{'SESSION_ID'},
                           -expires => '0'
                           );

if (exists $params{url}) {
    print $info->redirect(
                          -uri => $params{url},
                          -cookie => [$sess_cookie]
                          );
}
else {
    print $info->redirect(
                          -uri => 'index.cgi',
                          -cookie => [$sess_cookie]
                          );
}
