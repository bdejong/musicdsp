<?
	$handle=opendir('.');
	while (false!==($file = readdir($handle)))
	{
		if (!is_dir($file))
		{
			echo "<li><a href=\"$file\">$file</a></li>";
		}
	}
	closedir($handle);
?>