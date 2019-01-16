#!/usr/bin/perl
#
# Perl script to get weather data from OpenWeatherMap
#
use LWP::Simple;
use JSON;
use Net::MQTT::Simple "[MQTT Server]";


# set some variables
$cityid = "[City ID]";
$apikey = "[Your API key]";
$datamode = "json";
$apiurl = "http://api.openweathermap.org/data/2.5/weather?";
$units = "metric";

# Create the complete url

$request_url = $apiurl . "id=" . $cityid . "\&APPID=" . $apikey . "\&mode=" . $datamode . "\&units=" . $units;



my $json = get( $request_url );

# write result to file for later processing
open(FIL,">", "current.json") or die EXPR;
print FIL $json . "\n";
close FIL;

die "Could not get $request_url!" unless defined $json;

$output = decode_json($json);
#print Dumper($output);


# publish stuff to MQTT
# split wind speed into two separate values since domoticz do not handle floating numbers
$windspeed = $output->{'wind'}{'speed'};
($ws1,$ws2) = split(/\./,$windspeed);
$ws1 = $windspeed*10;

$windforecast = "{ \"idx\" : 38, \"nvalue\" : 0, \"svalue\" : \"" . $output->{'wind'}{'deg'} . ";N;" . $ws1 . ";0;0;0  \" }"  ; 
$tempforecast = "{ \"idx\" : 39, \"nvalue\" : 0, \"svalue\" : \"" . $output->{'main'}{'temp'} .  "\" }"  ;
$baroforecast = "{ \"idx\" : 40, \"nvalue\" : 0, \"svalue\" : \"" . $output->{'main'}{'pressure'} .  ";0\" }"  ;
$humiforecast = "{ \"idx\" : 41, \"nvalue\" : " . $output->{'main'}{'humidity'} . ".0, \"svalue\" : \"0\" }"  ;

publish "domoticz/in" => $windforecast;
sleep 1;
publish "domoticz/in" => $tempforecast;
sleep 1;
publish "domoticz/in" => $baroforecast;
sleep 1;
publish "domoticz/in" => $humiforecast;
