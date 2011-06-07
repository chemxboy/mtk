<?php
  
  /**
   * server.php
   * example server-side script for asd2nb.
   * plist.php is here: https://github.com/filipp/php_plist
   * @author Filipp Lepalaan <filipp@mcare.fi>
   * @package mtk
   */
   
  header('Content-Type: text/plain');

  if (!isset($_REQUEST['m'])) {
   exit("Sorry, have to know who you are first...");
  }

  $imgdir = '/data/nb/asd'; // edit this

  $model = $_REQUEST['m'];

  require "plist.php";

  foreach(glob("${imgdir}/*.nbi") as $nbi)
  {
    $p = new PropertyList("{$nbi}/NBImageInfo.plist");
    $a = $p->toArray();
    $ids = $a['EnabledSystemIdentifiers'];
    if (in_array($model, $ids)) {
      exit(basename($nbi).'/'.$a['RootPath']);
    }
  }

?>
