<?php

require __DIR__ . '/vendor/autoload.php';

date_default_timezone_set('UTC');

$options = getopt('fs:p:d:u:e:');

$remote_host = null;
if (isset($options['s'])) {
	$remote_host = $options['s'];
} else {
	fwrite(STDERR, "Missing server argument, -s.\n");
	exit();
}
$remote_port = (isset($options['p']) ? (int) $options['p'] : 22);
$remote_dir = (isset($options['d']) ? $options['d'] : '~');
$remote_user = (isset($options['u']) ? $options['u'] : get_current_user());

$local_dir = getcwd();

echo "Local: {$local_dir}\n";
echo "Remote: {$remote_user}@{$remote_host}:$remote_dir (on port {$remote_port})\n";
echo "\n";

if (!isset($options['f'])) {
	echo "DRY RUN: Not uploading (use -f to upload).\n\n";
}

$excludes = (isset($options['e']) ? explode(',', $options['e']) : array());
$excludes = array_filter($excludes, function($x) { return !empty($x); });

function is_exclude_file($path) {
	global $excludes;
	foreach ($excludes as $v) {
		if (substr($v, 0, 6) == "regex:") {
			$r = substr($v, 6);
			return @preg_match(substr($v, 6), $path);
		} else {
			return ($path == $v);
		}
	}
}

function list_local_files($dir, &$files, $relative='') {
	$path = $dir . ($relative ? '/' . $relative : '');
	$handle = opendir($path);
	while ($entry = readdir($handle)) {
		if ($entry == '.' || $entry == '..') continue;
		$entry_path = $path . '/' . $entry;
		$entry_path_relative = ($relative ? $relative . '/' : '') . $entry;
		if (is_exclude_file($entry_path_relative)) {
			echo "Local: Excluding '$entry_path_relative'!\n";
		} else if (!is_readable($entry_path)) {
			echo "Local: Cannot read '$entry_path'!\n";
		} else if (is_dir($entry_path)) {
			list_local_files($dir, $files, $entry_path_relative);
		} else if (is_file($entry_path)) {
			$files[$entry_path_relative] = stat($entry_path);
		} else {
			echo "Local: Not a file '$entry_path'!\n";
		}
	}
	closedir($handle);
}

echo "Connecting to {$remote_host}:{$remote_port}...\n";
$sftp = new \phpseclib\Net\SFTP($remote_host, $remote_port);
$rsa = new \phpseclib\Crypt\RSA();
$rsa->loadKey($sftp->getServerPublicHostKey());
$fingerprint = $rsa->getPublicKeyFingerprint();
echo "Server fingerprint: {$fingerprint}\n";

echo "Password for '{$remote_user}':\n";
$pass = fgets(STDIN);
echo "\033[1A\033[K";

$sftp->login($remote_user, trim($pass, "\n\r")) || exit();

echo "Connected...\n\n";

echo "Listing local files...\n";
$local_files = array();
list_local_files($local_dir, $local_files);

echo "Processing remote files...\n";

function upload_file($sftp, $path, $mtime) {
	global $remote_dir, $local_dir;
	$dir = str_replace('\\', '/', dirname("{$remote_dir}/{$path}"));
	$sftp->mkdir($dir, -1, true);
	$handle = fopen("{$local_dir}/{$path}", 'r');
	$sftp->put("{$remote_dir}/{$path}", $handle);
	$sftp->chmod(0644, "{$remote_dir}/{$path}");
	$sftp->touch("{$remote_dir}/{$path}", $mtime);
	fclose($handle);
}

$no_changes = true;

function process_remote_files($sftp, $dir, $relative='') {
	global $sftp, $local_files;
	$path = $dir . ($relative ? '/' . $relative : '');
	$list = $sftp->nlist($path);
	if (!$list) {
		return;
	}
	foreach ($list as $entry) {
		if ($entry == '.' || $entry == '..') continue;
		$entry_path = $path . '/' . $entry;
		$entry_path_relative = ($relative ? $relative . '/' : '') . $entry;
		if (is_exclude_file($entry_path_relative)) {
			echo "Remote: Excluding '$entry_path_relative'!\n";
			continue;
		}
		$type = $sftp->filetype($entry_path);
		if ($type == 'dir') {
			process_remote_files($sftp, $dir, $entry_path_relative);
		} else if ($type == 'file') {
			if (isset($local_files[$entry_path_relative])) {
				$stat = $sftp->stat($entry_path);
				$remote_mtime = $stat['mtime'];
				$local_mtime = $local_files[$entry_path_relative]['mtime'];
				if ($remote_mtime < $local_mtime) {
					$no_changes = false;
					echo "{$path}:\n";
					echo '  ', date('c', $local_mtime), ' > ', date('c', $remote_mtime), "\n";
					echo "  Local copy is newer, uploading...\n";
					if (isset($options['f'])) {
						upload_file($sftp, $entry_path_relative, $local_mtime);
					}
				} else if ($remote_mtime > $local_mtime) {
					$no_changes = false;
					echo "{$path}:\n";
					echo '  ', date('c', $local_mtime), ' < ', date('c', $remote_mtime), "\n";
					echo "  Remote copy is newer.\n";
				}
				unset($local_files[$entry_path_relative]);
			} else {
				$no_changes = false;
				echo "{$path}:\n  Extra file on remote.\n";
			}
		} else {
			echo "Remote: Not a file '$entry_path'!\n";
		}
	}
}

process_remote_files($sftp, $remote_dir);

foreach ($local_files as $path => $stat) {
	$no_changes = false;
	echo "{$path}:\n  New file, uploading...\n";
	if (isset($options['f'])) {
		upload_file($sftp, $path, $stat['mtime']);
	}
}

if ($no_changes) {
	echo "No changes.\n";
}

?>
