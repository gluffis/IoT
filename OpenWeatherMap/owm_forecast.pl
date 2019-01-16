#!/usr/bin/perl
#
# Perl script to get weather data from OpenWeatherMap
#
use LWP::Simple;
use JSON;
use Net::MQTT::Simple "[MQTT server];


# set some variables
$cityid = "[city id]"; # check at Openweathermap 
$apikey = "[API KEY]"; # Your API key
$datamode = "json";
$apiurl = "http://api.openweathermap.org/data/2.5/forecast?";
$units = "metric";

# Create the complete url
$request_url = $apiurl . "id=" . $cityid . "\&APPID=" . $apikey . "\&mode=" . $datamode . "\&units=" . $units . "\&cnt=1";

# Get the data from OpenWeathermap
my $json = get( $request_url );

# only for debugging
# write result to file for later processing
#open(FIL,">", "forecast.json") or die EXPR;
#print FIL $json . "\n";
#close FIL;

die "Could not get $request_url!" unless defined $json;

# decode Json data to something we can use
$output = decode_json($json);


# assign data to variables, this is probably no necessary
# could be done directly when creating domoticz strings
$forecast_time = $output->{list}[0]{dt_txt};
$forecast_temp =  $output->{list}[0]{main}{temp};
$forecast_humidity =  $output->{list}[0]{main}{humidity};
$forecast_pressure =  $output->{list}[0]{main}{pressure};
$forecast_wind_speed = $output->{list}[0]{wind}{speed};
$forecast_wind_heading = $output->{list}[0]{wind}{deg};
$forecast_cloudiness = $output->{list}[0]{clouds}{all};


# unly for debugging
#print "Forecast time\t\t: " . $forecast_time . "\n";
#print "Humidity forecasted\t: " . $forecast_humidity . " %\n";
#print "Temp forecasted\t\t: " . $forecast_temp . " C\n";
#print "Pressure forecasted\t: " . $forecast_pressure . " hPa \n";
#print "Wind speed and heading\t: " . $forecast_wind_speed . "m/s , " . $forecast_wind_heading . " deg\n";
#print "Cloudiness percent\t: " . $forecast_cloudiness . " % \n";


# publish stuff to MQTT
# split wind speed into two separate values since domoticz do not handle floating numbers
($ws1,$ws2) = split(/\./,$forecast_wind_speed);


# create proper strings for stuffing into Domoticz via MQTT
$windforecast = "{ \"idx\" : 38, \"nvalue\" : 0, \"svalue\" : \"" . $forecast_wind_heading . ";N;" . $ws1 . ";0;0;0  \" }"  ; 
$tempforecast = "{ \"idx\" : 39, \"nvalue\" : 0, \"svalue\" : \"" . $forecast_temp .  "\" }"  ;
$baroforecast = "{ \"idx\" : 40, \"nvalue\" : 0, \"svalue\" : \"" . $forecast_pressure .  ";0\" }"  ;
$humidforecast = "{ \"idx\" : 41, \"nvalue\" : " . $forecast_humidity . ", \"svalue\" : \"0\" }"  ;

publish "domoticz/in" => $windforecast;
sleep 1;
publish "domoticz/in" => $tempforecast;
sleep 1;
publish "domoticz/in" => $baroforecast;
sleep 1;
publish "domoticz/in" => $humidforecast;
