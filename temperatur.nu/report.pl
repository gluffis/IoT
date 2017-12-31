#!/usr/bin/perl
#
# Perl reporting script for temperatur.nu
# assumes input file has 2 values and we want to report the average
use LWP::UserAgent;

# set some basic variables
$tempfile = "/tmp/temperature";  # file containing temperature. 
$baseurl="http://www.temperatur.nu/rapportera.php?hash=[YourHash]&t=";

# read temperature from file
open(TEMPFIL,$tempfile);
$apa = <TEMPFIL>;
close $tempfile;

# clean input, and do some math
chomp($apa);
my ($temp1,$temp2) = split(/;/,$apa);
my $avgtemp = (($temp1+$temp2)/2);

# setup URL for posting
$url = join("",$baseurl,$avgtemp);

# create user agent , to avoid cloudflare filter. Just look like an old Firefox on Linux and everything
# will be fine
$ua = new LWP::UserAgent;
$ua->agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0");

# create HTTP object and post, don't really care about response , we simply hope for the best
$req = HTTP::Request->new(GET => $url);
$req->header('Accept' => 'text/html');
$res = $ua->request($req);
