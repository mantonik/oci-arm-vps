<html>
  <body>
    <hr>
    <br>This is html text, below is a hostname value from gethostname().
    <br>if you see it below then nginx and php are working correctly
    <?php
    echo "<br>";
    echo "<br>Site is running on host:";
    echo "<br>".gethostname(); // may output e.g,: sandie
    echo ""
    ?>
    <hr>

  </body>
</html>
