<html>
<body>

humidity: <?php echo $_GET["humidity"]; ?><br>
temp: <?php echo $_GET["temp"]; ?><br>
sensorname: <?php $_GET["sensorname"]; ?><br>

<?php

$myfile = fopen("envdata.csv", "a") or die("Unable to open file!");
$humi = $_GET["humidity"];
$temperature = $_GET["temp"];
$now = date("Y-m-d H:i:s");
$sensorn = $_GET["sensorname"];

$arr = array($now,$humi,$temperature,$sensorn,"\n");
$txt = join(";",$arr);
fwrite($myfile, $txt);

?>
</body>
</html>
