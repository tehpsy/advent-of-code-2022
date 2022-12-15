<?php
class Point {
  public readonly int $x;
  public readonly int $y;

  public function __construct(int $x, int $y) {
    $this->x = $x;
    $this->y = $y;
  }
}

class Range {
  public readonly int $start;
  public readonly int $end;

  public function __construct(int $start, int $end) {
    $this->start = $start;
    $this->end = $end;
  }
}

class Pair {
  public readonly Point $sensor;
  public readonly Point $beacon;
  public readonly int $distance;

  public function __construct(Point $sensor, Point $beacon) {
      $this->sensor = $sensor;
      $this->beacon = $beacon;
      $this->distance = abs($sensor->x - $beacon->x) + abs($sensor->y - $beacon->y);
  }
}

function make_pair($line): Pair {
  $strings = explode(":", $line);
  return new Pair(make_point($strings[0]), make_point($strings[1]));
}

function make_point(string $input): Point {
  $pattern = "/-?\d+/";
  preg_match_all($pattern, $input, $matches);  
  return new Point(intval($matches[0][0]), intval($matches[0][1]));
}

$lines = explode("\n", file_get_contents('./input.txt', true));
$pairs = array_map(function ($line) { return make_pair($line); }, $lines);

part1($pairs);
part2($pairs);

function min_in($ranges) {
  $min = null;
  foreach ($ranges as $range) {
    if ($min == null || $range->start < $min) { $min = $range->start; }
  }
  return $min;
}

function max_in($ranges) {
  $max = null;
  foreach ($ranges as $range) {
    if ($max == null || $range->end > $max) { $max = $range->end; }
  }
  return $max;
}

function part1($pairs) {
  $ranges = array();
  $y=2000000;
  foreach ($pairs as $pair) {
    $val = $pair->distance - abs($pair->sensor->y - $y);
    if ($val < 0) { continue; }
    $x_min = $pair->sensor->x - $val;
    $x_max = $pair->sensor->x + $val;
    array_push($ranges, new Range($x_min, $x_max));
  }

  $min = min_in($ranges);
  $max = max_in($ranges);
  $count = count_occupied($ranges, $min, $max) - count_beacons_on_line($pairs, $y);
  print_r("Part 1: $count\n");
}

function part2($pairs) {
  $lines = array_reduce($pairs, function ($acc, $pair) {
    $sensor = $pair->sensor;
    $x = $sensor->x;
    $y = $sensor->y;
    $d = $pair->distance;
    array_push($acc, $y - $x + $d);
    array_push($acc, $y - $x - $d);
    array_push($acc, $y + $x + $d);
    array_push($acc, $y + $x - $d);
    return $acc;
  }, array());
  
  $gap = find_gap($lines);
  $freq = 4000000 * $gap->x + $gap->y;
  print_r("Part 2: $freq\n");
}

function find_gap($lines): Point {
  sort($lines);
  $y_crossing_values = array();
  for ($i = 0; $i < count($lines) - 1; $i++) {
    if ($lines[$i + 1] == $lines[$i] + 2) {
      array_push($y_crossing_values, $lines[$i] + 1);
    }
  }
  $top = $y_crossing_values[1];
  $bottom = $y_crossing_values[0];
  $x = ($top - $bottom)/2;
  $y = $x + $bottom;
  return new Point($x, $y);
}

function count_beacons_on_line($pairs, $y) {
  $beacons_to_ignore = array_filter($pairs, function ($pair) use($y) { return $pair->beacon->y == $y; });
  $x_values_to_ignore = array_unique(array_map(function ($pair) { return $pair->beacon->x; }, $beacons_to_ignore));
  return count($x_values_to_ignore);
}

function count_occupied($ranges, $min, $max): int {
  $count = 0;
  for ($i = $min; $i <= $max; $i++) {
    foreach ($ranges as $range) {
      if ($i >= $range->start and $i <= $range->end) {
        $count++;
        break;
      }
    }
  }

  return $count;
}
?>