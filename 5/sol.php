<?php
$data = explode("\n\n", file_get_contents('./input.txt', true));
$start_state = explode("\n", $data[0]);
$instructions = explode("\n", $data[1]);

array_pop($start_state);

function make_column(int $index, $start_state) {
  $values = array_map(function ($arr) use ($index) { return $arr[4 * $index + 1]; }, $start_state);
  $filtered_array = array_filter($values, function ($arr) { return $arr !== " "; });
  return array_reverse($filtered_array);
}

function make_columns($start_state) {
  $num_columns = (strlen($start_state[0]) + 1) / 4;
  $columns = [];
  for ($column = 0; $column < $num_columns; $column++) {
    array_push($columns, make_column($column, $start_state));
  }
  return $columns;
}

function get_string($columns) {
  $filtered_array = array_filter($columns, function ($arr) { return !empty($arr); });
  $final_elements = array_map(function ($arr) { return $arr[count($arr) - 1]; }, $filtered_array);
  return implode('', $final_elements);
}

function parse($instruction) {
  $pattern = "/move (\d+) from (\d+) to (\d+)/i";
  preg_match($pattern, $instruction, $matches);
  array_shift($matches);
  return $matches;
}

function perform(& $columns, $instructions, $fifo) {
  for ($instruction = 0; $instruction < count($instructions); $instruction++) {
    [$num_crates, $from_index, $to_index] = parse($instructions[$instruction]);

    $fromColumn = &$columns[$from_index - 1];
    $toColumn = &$columns[$to_index - 1];
    $popped = array_splice($fromColumn, count($fromColumn) - $num_crates, $num_crates);
    
    if ($fifo) {
      $popped = array_reverse($popped);
    }

    $toColumn = array_merge($toColumn, $popped);
  }
}

$part1 = make_columns($start_state);
perform($part1, $instructions, true);
print_r(get_string($part1));
echo "\n";

$part2 = make_columns($start_state);
perform($part2, $instructions, false);
print_r(get_string($part2));
echo "\n";
?>