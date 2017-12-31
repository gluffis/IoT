#!/usr/bin/perl
#
# Get and update rrd data for 1wire sensors
# The assumption is that the rrd file exists
# The code could probably be cleaned and optimzed
#

use RRDs;
use RRD::Simple;

# Which sensors do we want to check
# in format sensorname:rrd file name:description
@sensors = qw(
            10.0E4141020800:sensor1.rrd:Sensor1
            10.482531020800:sensor2.rrd:Sensor2            
            );

$sensorpath = '/mnt/1wire';   # path to where sensors ar mounted
$rrdpath = '/data/1wire/';    # path for RRD files
$grafpath = '/data/1wire/';   # path for graph output

# iterate over all sensors and get the temperature, update rrd file and create the graph
foreach $sensordata (@sensors) {
    my ($sensor,$rrdfile,$desc) = split(/:/,$sensordata);   # split into variables for later use
    open(SENSOR,"$sensorpath/$sensor/temperature"); # open filehandle for sensor
    my $apa = <SENSOR>;                            # read temp into $apa variable
    close SENSOR;                                  # close filehandle
    update_rrd_data($rrdfile,$apa);                # update rrd file
    create_graf($rrdfile,$desc);                   # generate graph
}

sub update_rrd_data {
    my $fil = $_[0];
    my $data = $_[1];
    my $rrdfil = join("",$rrdpath,$fil) ;   # join to complete path
    # Create an interface object
    my $rrd = RRD::Simple->new( file => $rrdfil );  # create new object for RRD file
    $rrd->update( outsideTemp => $data);            # update the RRD file
}

sub create_graf {
         my $rrdfile = $_[0];
         my $desc = $_[1];
         my $rrdfil = join("",$rrdpath,$rrdfile) ;  # join to complete path
         my $basnamn = lc($desc);                   # we want lowecase description
         my $rrd = RRD::Simple->new( file => $rrdfil ); # open RRD file to create graph from
         # create the graphs ,daily,weekly,monthly,yearly and 3 years span
         my %rtn = $rrd->graph($rrdfil,
             destination => $grafpath,
             basename => $basnamn,
             timestamp => "both", # graph, rrd, both or none
             title => "Temp: $desc", 
             sources => [ qw(outsidetemp ) ],
             source_colors => [ qw(ff0000 aa3333 000000) ],
             source_labels => [ ("$desc") ],
             source_drawtypes => [ qw(LINE1) ],
             line_thickness => 1,
             extended_legend => 1,
             width => 600,
             height => 200,
             slope_mode => "" #slope_mode
         );
}
