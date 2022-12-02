import system/io
import std/sequtils
import std/strutils
import std/sugar
import std/math

type
  Shape = enum
    Rock, Paper, Scissors

proc shape_score(shape: Shape): int =
  case shape:
  of Rock: return 1
  of Paper: return 2
  of Scissors: return 3

proc shape_beats(shape: Shape): Shape =
  case shape:
  of Rock: return Scissors
  of Paper: return Rock
  of Scissors: return Paper

proc round_score(opponent, your: Shape): int =
  let shape_score = shape_score(your)
  if your == opponent:
    shape_score + 3
  elif opponent == shape_beats(your):
    shape_score + 6
  else:
    shape_score

proc text_for(filename: string): string =
  let f = open(filename)
  defer: f.close()
  readAll(f)

func letter_to_shape(letter: char): Shape =
  case letter:
  of 'A', 'X': return Rock
  of 'B', 'Y': return Paper
  of 'C', 'Z': return Scissors
  else: return Rock

proc process_line(line: string): (Shape, Shape) =
  let letters = line.split(" ")
  let shapes = letters.map(x => letter_to_shape(x[0])) 
  (shapes[0], shapes[1])

let score = text_for("input.txt")
.split('\n')
.map(x => process_line(x))
.map(x => round_score(x[0], x[1]))
.sum

echo(score)
