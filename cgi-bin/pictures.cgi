#!/usr/bin/perl

BEGIN {
        use lib "/Library/WebServer/Lib";
      }

use strict;
use Pictures;

my $app = new Pictures;
$app->run();
