<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include("../mastodon/bot.php");

function tweetThis($tweet) {
//    $masto = mastodon("kansanradio");
//    $masto->statuses()->post(["status" => $tweet]);
    $bsky = bsky("kansan-radio");
    $bsky->repo()->createRecord($tweet, ["fi"]);
}

function fail($message) {
    print($message . PHP_EOL);
    exit(1);
}

function findEpisodeFile($directory, $episodeId, $extension) {
    $files = glob($directory . '/*-' . $episodeId . '.' . $extension);

    if (count($files) !== 1) {
        fail("Expected one .$extension file for episode $episodeId in $directory.");
    }

    return $files[0];
}

function prepareTranscript($srt) {
    $lines = preg_split('/\R/u', $srt);
    $text = [];

    foreach ($lines as $line) {
        $line = trim($line);

        if ($line === '' || preg_match('/^\d+$/', $line)) {
            continue;
        }

        if (preg_match('/^\d{2}:\d{2}:\d{2},\d{3}\s+-->\s+\d{2}:\d{2}:\d{2},\d{3}$/', $line)) {
            continue;
        }

        $text[] = strip_tags($line);
    }

    return trim(preg_replace('/\s+/u', ' ', implode(' ', $text)));
}

$rootDir = __DIR__;
$dataDir = $rootDir . '/data';
$episodeIdFile = $dataDir . '/last_episode_id.txt';
$localEpisodeIdFile = $dataDir . '/latest_episode_id.txt';
$finalTranscriptFile = $dataDir . '/final.txt';

if (!is_readable($episodeIdFile)) {
    fail("Episode ID file is missing: $episodeIdFile");
}

$episodeId = trim(file_get_contents($episodeIdFile));
if ($episodeId === '') {
    fail("Episode ID file is empty: $episodeIdFile");
}

$localEpisodeId = is_readable($localEpisodeIdFile)
    ? trim(file_get_contents($localEpisodeIdFile))
    : '';

if ($episodeId !== $localEpisodeId) {
    $metadataFile = findEpisodeFile($dataDir . '/metadata', $episodeId, 'json');
    $srtFile = findEpisodeFile($dataDir . '/transcripts', $episodeId, 'srt');

    $metadata = json_decode(file_get_contents($metadataFile), true);
    $title = $metadata[0]['episode_title'] ?? null;

    if (!is_string($title) || $title === '') {
        fail("Episode title is missing from $metadataFile");
    }

    $preparedTranscript = prepareTranscript(file_get_contents($srtFile));
    if ($preparedTranscript === '') {
        fail("Transcript is empty after cleaning: $srtFile");
    }

    file_put_contents($finalTranscriptFile, $preparedTranscript . PHP_EOL);

    tweetThis(mb_substr($title, 0, 280));
    file_put_contents($localEpisodeIdFile, $episodeId . PHP_EOL);

    print "New episode prepared for tweeting: $title" . PHP_EOL;
    die();
}

$fname = $finalTranscriptFile;
if (!is_readable($fname)) {
    print "No prepared transcript to tweet." . PHP_EOL;
    exit(0);
}

$c = file_get_contents($fname);
$tweet = mb_substr($c, 0, 280);
if (mb_strlen($tweet) == 280) {
    $pos1 = 1; // mb_strrpos($tweet, ",");
    $pos2 = mb_strrpos($tweet, ".");
    $pos3 = mb_strrpos($tweet, "!");
    $pos4 = mb_strrpos($tweet, "?");
    $pos5 = 1; // mb_strrpos($tweet, ";");
    $cut = max($pos1, $pos2, $pos3, $pos4, $pos5);
    if ($cut < 50) {
        $cut = mb_strrpos($tweet, " ");
    }

    $tweet = trim(mb_substr($tweet, 0, $cut + 1));
    $c = trim(mb_substr($c, mb_strlen($tweet) + 1));
} else {
    $c = "";
}
file_put_contents($fname, $c);
if (!empty($tweet)) {
    // Clean up the tweet.
    $tweet = str_replace("*", "", $tweet);
    $tweet = str_replace("\n", " ", $tweet);
    $tweet = str_replace(chr(13), " ", $tweet);
    $tweet = str_replace("  ", " ", $tweet);

    tweetThis($tweet);
}

print '<pre>';
print $tweet . "\n";
print mb_strlen($tweet);
