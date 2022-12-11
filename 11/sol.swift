#!/usr/bin/env swift
import Foundation

class Monkey {
  var items: [Int]
  let operation: Operation
  let test: (value: Int, trueIndex: Int, falseIndex: Int)
  var processCount = 0
  init (
    items: [Int],
    operation: Operation,
    test: (value: Int, trueIndex: Int, falseIndex: Int)
  ) {
    self.items = items
    self.operation = operation
    self.test = test
  }
}

enum Operation {
  case square
  case add(Int)
  case subtract(Int)
  case multiply(Int)
  case divide(Int)

  init(_ string: String) {
    let components = string.components(separatedBy: " ")
    let value = Int(components[1])
    if components[1] == "old" { self = .square }
    else if components[0] == "+" { self = .add(value!)}
    else if components[0] == "-" { self = .subtract(value!)}
    else if components[0] == "*" { self = .multiply(value!)}
    else if components[0] == "/" { self = .divide(value!)}
    else { fatalError() }
  }
}

extension Int {
  func applying(_ operation: Operation) -> Self {
    switch operation {
    case .square: return self * self
    case .add(let value): return self + value
    case .subtract(let value): return self - value
    case .multiply(let value): return self * value
    case .divide(let value): return self / value
    }
  }
}

func parse(_ string: String) -> Monkey {
  let lines = string.components(separatedBy: "\n")
  let items = lines[1]
    .replacingOccurrences(of: "  Starting items: ", with: "")
    .components(separatedBy: ",")
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .map { Int($0)! }
  let operation = Operation(lines[2].replacingOccurrences(of: "  Operation: new = old ", with: ""))
  let test = (
    Int(lines[3].replacingOccurrences(of: "  Test: divisible by ", with: ""))!,
    Int(lines[4].replacingOccurrences(of: "    If true: throw to monkey ", with: ""))!,
    Int(lines[5].replacingOccurrences(of: "    If false: throw to monkey ", with: ""))!
  )
  return Monkey(items: items, operation: operation, test: test)
}

let path = FileManager.default.currentDirectoryPath.appending("/input.txt")
let monkeyStrings = try! String(contentsOfFile: path, encoding: String.Encoding.utf8).components(separatedBy: "\n\n")

func run(rounds: Int, reduction: Int) -> Int {
  let monkeys = monkeyStrings.map { parse($0) }

  for _ in (0..<rounds) {
    for monkey in monkeys {
      monkey.processCount += monkey.items.count
      for item in monkey.items {
        let newValue = item.applying(monkey.operation) % reduction
        let index = newValue % monkey.test.0 == 0 
          ? monkey.test.1 
          : monkey.test.2
        
        monkeys[index].items.append(newValue)
      }
      monkey.items.removeAll()
    }  
  }

  return monkeys
    .map { $0.processCount }
    .sorted(by: { $0 > $1 })
    .prefix(2)
    .reduce(1, { $0 * $1 })
}

let part1 = run(rounds: 20, reduction: 3)
print(part1)

let reduction = monkeyStrings
  .map { parse($0).test.0 }
  .reduce(1, { $0 * $1 })
let part2 = run(rounds: 10000, reduction: reduction)
print(part2)