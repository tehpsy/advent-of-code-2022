import system/io
import std/sequtils
import std/strutils
import std/sugar
import std/math
import std/options

type
  Shape = enum
    Rock, Paper, Scissors

type
  Outcome = enum
    Lose, Draw, Win

proc shape_score(shape: Shape): int =
  case shape:
  of Rock: return 1
  of Paper: return 2
  of Scissors: return 3

proc shape_that_loses_to(shape: Shape): Shape =
  case shape:
  of Rock: return Scissors
  of Paper: return Rock
  of Scissors: return Paper

proc shape_that_wins_to(shape: Shape): Shape =
  case shape:
  of Rock: return Paper
  of Paper: return Scissors
  of Scissors: return Rock

proc round_score(opponent, your: Shape): int =
  let shape_score = shape_score(your)
  if your == opponent:
    shape_score + 3
  elif opponent == shape_that_loses_to(your):
    shape_score + 6
  else:
    shape_score

proc text_for(filename: string): string =
  let f = open(filename)
  defer: f.close()
  readAll(f)

func letter_to_shape(letter: char): Option[Shape] =
  case letter:
  of 'A': some(Rock)
  of 'B': some(Paper)
  of 'C': some(Scissors)
  else: none(Shape)

func letter_to_outcome(letter: char): Option[Outcome] =
  case letter:
  of 'X': some(Lose)
  of 'Y': some(Draw)
  of 'Z': some(Win)
  else: none(Outcome)

func make_choice(opponent: Shape, outcome: Outcome): Shape =
  case outcome:
  of Lose: shape_that_loses_to(opponent)
  of Draw: opponent
  of Win: shape_that_wins_to(opponent)

proc process_line(line: string): (Shape, Shape) =
  let letters = line.split(" ")
  let opponent = letter_to_shape(letters[0][0]).get()
  let outcome = letter_to_outcome(letters[1][0]).get()
  (opponent, make_choice(opponent, outcome))

let score = text_for("input.txt")
  .split('\n')
  .map(x => process_line(x))
  .map(x => round_score(x[0], x[1]))
  .sum

echo(score)