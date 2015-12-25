package Pictures;

use strict;
use warnings; 
use CGI;
use JSON;
use Template;
use URI::Escape;
use Image::ExifTool qw(:Public);
use Time::Piece;
use File::Basename;
use File::Type;
use debug::utils;

sub new {
    my $class = shift;

    my %params = @_;

    my $self = {};
    bless $self, $class;

    my $q = $self->{cgi} = new CGI;

    debug::utils->Traceback({map {$_ => $q->param($_)} $q->param()});
    $self->{template} = Template->new({INCLUDE_PATH => ['/Library/WebServer/Templates']});
    $self->{input} = {map {$_ => uri_unescape($q->param($_))} $q->param()};
    # single quote is missed by uri_unescape, so convert it manually
    $self->{input}->{path} =~ s/%21/'/g;
    # get the realpath and remove the trailing carriage return
    $self->{input}->{path} = (split /\n/, `/usr/local/bin/greadlink -f "$self->{input}->{path}"`)[0];

    return $self;
}

sub run {
    my $self = shift;

    my $q = $self->{cgi};
    my $tt = $self->{template};
    my $output;

    my @listing = split /\n/, `ls -al "$self->{input}->{path}" | grep 'drwx' | sort -f -k 9`;
    my @files = split /\n/, `ls -al "$self->{input}->{path}" | grep -v 'drwx' | grep -v '_thumb\.' | sort -f -k 9`;
    push @listing, @files;
    my $file_count = scalar @listing;
    if ($file_count > 1) {
        my $files = [];
        for my $file (@listing) {
            my @file_parts = split '\s+', $file;
            if (($#file_parts >= 8) && ($file_parts[8] !~ /^\.$/) && ($file_parts[8] !~ /^\./)) {
                my $filename = join(' ', @file_parts[8..$#file_parts]);
                my @filename_parts = split /\./, $filename;
                my $thumbnail = join('.', @filename_parts[0 .. $#filename_parts-1]) . '_thumb.jpg';
                my $thumbnail_path = "$self->{input}->{path}/$thumbnail";
                if (-e $thumbnail_path) {
                    $thumbnail = "/files/$$.$thumbnail";
                    `ln -s "$thumbnail_path" "/Library/WebServer/Documents/$thumbnail"`;
                } else {
                    $thumbnail = undef;
                }
                my $image_info = ImageInfo("$self->{input}->{path}/$filename");
                my $info = "";
                if ($image_info->{Error}) {
                    $info = get_standard_date(`/usr/local/opt/coreutils/libexec/gnubin/date +"%Y:%m:%d %H:%M:%S" -r "$self->{input}->{path}/$filename"`);
                }
                else {
                    if ($image_info->{FileType} eq 'HTML') {
                        next;
                    }
                    my $temp_data = {map {$_ => $image_info->{$_}} grep (/Date/, keys %{$image_info})};
                    # the date may just be a bunch of spaces so look for a number
                    if (defined($image_info->{CreateDate}) && $image_info->{CreateDate} =~ /[1-9]+/) {
                        $info .= get_standard_date($image_info->{CreateDate}) . "<br>"; 
                    }
                    elsif (defined($image_info->{FileModifyDate}) && $image_info->{FileModifyDate} =~ /[1-9]+/) {
                        $info .= get_standard_date($image_info->{FileModifyDate}) . "<br>"; 
                    }
                    else {
                        debug::utils->Log($temp_data);
                    }
                    $info .= $file_parts[4] . " bytes";
                    if ($image_info->{ImageWidth}) {
                        $info .= "<br>Width: " . $image_info->{ImageWidth};
                    }
                    if ($image_info->{ImageHeight}) {
                        $info .= "<br>Height: " . $image_info->{ImageHeight};
                    }
                    if ($image_info->{FileType}) {
                        $info .= "<br>File Type: " . $image_info->{FileType};
                    }
                }
                push @{$files}, [$info, $filename, $thumbnail];
            }
        }
        #  define data 
        my $file = (split /$self->{input}->{base}/, $self->{input}->{path})[1];
        my  $vars = {
            path => $self->{input}->{path},
            base => $self->{input}->{base},
            title => "Album $file",
            files => $files,
        };
    
        $tt->process('pictures.tt', $vars, \$output) || die $tt->error();
    }
    else {
        my $file_name = basename($self->{input}->{path});
        my $file = "/files/$$.$file_name";
        `ln -s "$self->{input}->{path}" "/Library/WebServer/Documents/$file"`;
        my $ft = File::Type->new();
        my $mime_type = $ft->mime_type($self->{input}->{path});
        my  $vars = {
            title => $file_name,
            file => $file,
            mime_type => $mime_type,
        };
    
        if ($mime_type =~ "image") {
            $tt->process('image.tt', $vars, \$output) || die $tt->error();
        }
        elsif ($mime_type eq "application/pdf") {
            $tt->process('pdf.tt', $vars, \$output) || die $tt->error();
        }
        elsif ($mime_type eq "application/octet-stream") {
            $tt->process('video.tt', $vars, \$output) || die $tt->error();
        }
        elsif (($mime_type eq "video/mpeg") ||
               ($mime_type eq "video/quicktime")) {
            $tt->process('mpeg.tt', $vars, \$output) || die $tt->error();
        }
        else {
            $tt->process('default.tt', $vars, \$output) || die $tt->error();
        }
    }
    $self->send_success_json({text => $output, count => $file_count});
}

sub send_success_json {
    my $self = shift;
    my $additional_properties = shift;

    $self->send_json(1,'',$additional_properties);
}

sub send_json {
    my $self = shift;
    my $request_successfully_completed = shift;
    my $error_message= shift;
    my $additional_properties = shift;

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

sub get_standard_date {
    my $in_date = shift;
    chomp($in_date);

    my $dt = Time::Piece->strptime(substr($in_date, 0, 19), '%Y:%m:%d %H:%M:%S');
    return $dt->strftime('%b %e, %Y %H:%M:%S');
}

1;
