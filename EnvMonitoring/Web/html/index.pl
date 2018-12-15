#!/usr/bin/perl
#
# Perl script for generating graphs
#  just the graphs, no fancy html
#

use DBI;
use GD::Graph;
use Mortal::Kombat;
use Time::HiRes qw( time );

my $start = time();

$mysqlhost = 'localhost';
$mysqluser = "kartong";
$mysqlpass = "password";
$database = "environmentdata";

$dsn = "dbi:mysqlPP:database=$database;host=$mysqlhost";

    $dbh = DBI->connect($dsn, $mysqluser,$mysqlpass) || fatality "Error connectiong to database\n";

    $drh = DBI->install_driver("mysqlPP");
    $sth = $dbh->prepare("SELECT * FROM sensordata WHERE recorded_at >= CURDATE() - INTERVAL 7 DAY");
    $sth->execute;

 while (my $ref = $sth->fetchrow_arrayref()) {
   push @datatemp,$ref->[2];
   push @datahumi,$ref->[3];    
   push @dateref,$ref->[4];
  }
    $sth->finish;

my $end = time();
my $runtime = sprintf("%.16s", $end - $start);
print "This script took $runtime seconds to execute\n";



flawless victory;