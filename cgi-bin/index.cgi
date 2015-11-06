#!/usr/bin/perl

BEGIN {
        use lib "/Library/WebServer/Lib";
      }

use strict;
use Main;

my $app = new Main;
$app->run();
