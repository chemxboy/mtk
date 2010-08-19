<?php

$interval = 3;
$infile = '/tmp/ping.out';
$outfile = $infile.'.csv';

$ts = filemtime($infile);
$ifh = fopen($infile, 'r') or die('Failed to open ' . $infile);
$ofh = fopen($outfile, 'w+') or die('Failed to open ' . $outfile);

$i = 0;
$offset = 0;
$data = array();
$columns = array();
$max_ping = 0;
$min_ping = 0;

while (!feof($ifh)) {
  $line = fgets($ifh, 4096);
  preg_match('/from (\d+\.\d+\.\d+\.\d+) icmp_seq=(\d+) ttl=\d+ time=(\d+\.\d+)/', $line, $m);
  if (!empty($m)) {
    $ts += $interval;
    $time = $m[2];
    if ($time > $max_ping) {
      $max_ping = $time;
    }
    $data[] = sprintf('{%s}', $time);
    $date = @date('U', $ts);
    $columns[] = sprintf('"%s"', $date);
    fwrite($ofh, "$date, $time\n");
  }
  $i++;
}

fclose($ifh);
fclose($ofh);

// Keynote can't really handle more
if ($i > 100) {
  exit();
}

$data = implode(',', $data);
$columns = implode(',', $columns);

$as =<<<EOT
  tell application "Keynote"
  	set theData to {{$data}}
  	set theSlide to (slide 1) of first slideshow
  	tell theSlide
  		add chart row names {{$columns}} column names {"ping"} ¬
  			data theData type "line_2d" group by "column"
  	end tell
  end tell
EOT;

file_put_contents('/tmp/ping.scpt', $as);
`osascript /tmp/ping.scpt`;
echo "Max ping: $max_ping";
?>
