#!/usr/bin/perl

use strict;
use CGI;

my $q = new CGI;

print 
    $q->header('text/html'),
    $q->start_html('A Simple CGI Page'),
    $q->h1('A Simple CGI Page'),
    $q->start_form,
    'Name: ',
    $q->textfield('name'), $q->br,
    'Age: ',
    $q->textfield('age'), $q->p,
    $q->submit('Submit!'),
    $q->end_form, $q->p,
    $q->hr;
 
if ( $q->param('name') ) {
    print 'Your name is ', $q->param('name'), $q->br;
}
 
if ( $q->param('age') ) {
    print 'You are ', $q->param('age'), ' years old.';
}
 
print $q->end_html;
