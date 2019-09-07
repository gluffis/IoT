#!/usr/bin/perl
#
# Script for getting values from a DHT22 sensor attached to GPIO on a raspberry pi
# stuffs data in a MQTT stream aimed for domoticz 
# Requires pigpiod and some perl libraries
# Also need dummy sensors added in Domoticz to get proper index values
#

# import some libraries
use RPi::PIGPIO;
use RPi::PIGPIO::Device::DHT22;
use Net::MQTT::Simple;
use Math::Round;

# Define MQTT server
my $mqtt = Net::MQTT::Simple->new("<enter MQTT host here>");
 
# Define where to talk to pigpiod
my $pi = RPi::PIGPIO->connect('127.0.0.1');
 
# Define the sensor and which pin to read
my $dht22 = RPi::PIGPIO::Device::DHT22->new($pi,4);
 
# Read values
$dht22->trigger(); #trigger a read
$temp = $dht22->temperature;
$humi = $dht22->humidity; 

# round the humidity since domoticz kinda dont want floats for humidity
$humi = round($humi);

# push values to MQTT, update sensor index values to suit your needs
$mqtt->publish("domoticz/in" => "{ \"idx\" : 77, \"nvalue\" : 0, \"svalue\" : \"$temp\" }");
$mqtt->publish("domoticz/in" => "{ \"idx\" : 76, \"nvalue\" : $humi, \"svalue\" : \"0\" }");
