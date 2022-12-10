package main

import (
  "fmt"
  "strings"
  "io/ioutil"
  "strconv"
  "math"
)

const crt_width = 40
const crt_height = 6

func main() {
  content, _ := ioutil.ReadFile("input.txt")
  instructions := strings.Split(string(content), "\n")
  signal_strength_check_counter := 0
  signal_strength_cycle_checks := []int {20, 60, 100, 140, 180, 220}
  signal_strength_sum := 0
  cycle := 0
  register := 1
  output := ""

  for _, instruction := range instructions {
    instruction_cycle_count, add_value := parse(instruction)

    for i := 0 ; i < instruction_cycle_count ; i++ {
      cycle += 1 
      
      if cycle == signal_strength_cycle_checks[signal_strength_check_counter] {
        signal_strength_sum += cycle * register
        signal_strength_check_counter += 1
        signal_strength_check_counter %= len(signal_strength_cycle_checks)
      }

      output += pixel(register, cycle)
      
      if i == instruction_cycle_count - 1 {
        register += add_value
      }
    }
  }

  fmt.Println("Part 1", signal_strength_sum)
  print_crt(output)
}

func parse(instruction string) (instruction_cycle_count int, add_value int) {
  if instruction == "noop" {
    return 1, 0
  } else {
    add_value, _ = strconv.Atoi(instruction[5:])
    return 2, add_value		
  }
}

func pixel(register, cycle int) string {
  if math.Abs(float64(register - ((cycle - 1) % crt_width))) <= 1 {
    return "#"
  } else {
    return "."
  }
}

func print_crt(output string) {
  fmt.Println("Part 2:")
  for i := 0 ; i < crt_height ; i++ {
    fmt.Println(output[i * crt_width : (i + 1) * crt_width])
  }
}