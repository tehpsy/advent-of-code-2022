#!/usr/bin/env swift
import Foundation

class Rock {
  let shape: Shape
  let width: UInt8
  let height: UInt8

  enum Shape: CaseIterable {
    case hline, plus, capl, vline, box
  }

  init(shape: Shape) { 
    self.shape = shape
    switch shape {
      case .hline: self.width = 4; self.height = 1
      case .plus: self.width = 3; self.height = 3
      case .capl: self.width = 3; self.height = 3
      case .vline: self.width = 1; self.height = 4
      case .box: self.width = 2; self.height = 2
    }
  }
  
  lazy var masks: [UInt8] = {
    switch shape {
      case .hline: return [0b1111000]
      case .plus: return [0b0100000, 0b1110000, 0b0100000]
      case .capl: return [0b1110000, 0b0010000, 0b0010000]
      case .vline: return [0b1000000, 0b1000000, 0b1000000, 0b1000000]
      case .box: return [0b1100000, 0b1100000]
    }
  }()

  func canMoveDown(_ lines: [UInt8], _ x: UInt8, _ y: Int) -> Bool {
    if y == 0 { return false }
    let shift = 7 - width - x
    let shapeLines = Array(lines[y ..< y + Int(height)])
    let nextLine = lines[y - 1]
    switch shape {
      case .hline: return nextLine & (0b1111 << shift) == 0
      case .plus: return (nextLine & (0b010 << shift) == 0) && (shapeLines[0] & (0b101 << shift) == 0)
      case .capl: return (nextLine & (0b111 << shift) == 0)
      case .vline: return (nextLine & (1 << shift) == 0)
      case .box: return (nextLine & (0b11 << shift) == 0)
    }
  }

  func canMoveRight(_ lines: [UInt8], _ x: UInt8, _ y: Int) -> Bool {
    if 7 - width - x <= 0 { return false }
    let shapeLines = Array(lines[y ..< y + Int(height)])
    switch shape {
      case .hline: return shapeLines[0] & (1 << (7 - 1 - width - x)) == 0
      case .plus: return (shapeLines[0] & (1 << (7 - width - x)) == 0) && (shapeLines[1] & (1 << (7 - 1 - width - x)) == 0) && (shapeLines[2] & (1 << (7 - width - x)) == 0)
      case .capl, .vline, .box: return shapeLines.allSatisfy { $0 & (1 << (7 - 1 - width - x)) == 0 } 
    }
  }

  func canMoveLeft(_ lines: [UInt8], _ x: UInt8, _ y: Int) -> Bool {
    if x == 0 { return false }
    let shapeLines = Array(lines[y ..< y + Int(height)])
    switch shape {
      case .hline: return shapeLines[0] & (1 << (7 - x)) == 0
      case .plus: return (shapeLines[0] & (1 << (7 - 1 - x)) == 0) && (shapeLines[1] & (1 << (7 - x)) == 0) && (shapeLines[2] & (1 << (7 - 1 - x)) == 0)
      case .capl: return (shapeLines[0] & (1 << (7 - x)) == 0) && (shapeLines[1] & (1 << (7 - 2 - x)) == 0) && (shapeLines[2] & (1 << (7 - 2 - x)) == 0)
      case .vline, .box: return shapeLines.allSatisfy { $0 & (1 << (7 - x)) == 0 } 
    }
  }
}

// assert(Rock(shape: .hline).canMoveLeft([0b0000000], 1, 0) == true)
// assert(Rock(shape: .hline).canMoveLeft([0b0000000], 3, 0) == true)
// assert(Rock(shape: .hline).canMoveLeft([0b0010000], 3, 0) == false)
// assert(Rock(shape: .hline).canMoveLeft([0b1000000], 1, 0) == false)
// assert(Rock(shape: .hline).canMoveLeft([0b0000000], 0, 0) == false)
// assert(Rock(shape: .hline).canMoveRight([0b0000000], 0, 0) == true)
// assert(Rock(shape: .hline).canMoveRight([0b0000000], 2, 0) == true)
// assert(Rock(shape: .hline).canMoveRight([0b0010000], 3, 0) == false)
// assert(Rock(shape: .hline).canMoveRight([0b0000010], 1, 0) == false)
// assert(Rock(shape: .hline).canMoveRight([0b0000100], 0, 0) == false)
// assert(Rock(shape: .hline).canMoveDown([0b0100000, 0b0000000], 2, 1) == true)
// assert(Rock(shape: .hline).canMoveDown([0b0010000, 0b0000000], 3, 1) == true)
// assert(Rock(shape: .hline).canMoveDown([0b0000001, 0b0000000], 0, 1) == true)
// assert(Rock(shape: .hline).canMoveDown([0b1111111, 0b0000000], 3, 1) == false)
// assert(Rock(shape: .hline).canMoveDown([0b0000001, 0b0000000], 3, 1) == false)
// assert(Rock(shape: .hline).canMoveDown([0b0000010, 0b0000000], 3, 1) == false)
// assert(Rock(shape: .hline).canMoveDown([0b0000100, 0b0000000], 3, 1) == false)
// assert(Rock(shape: .hline).canMoveDown([0b0001000, 0b0000000], 3, 1) == false)
// assert(Rock(shape: .plus).canMoveLeft([0b0000000], 3, 0) == true)



let maxRocks = 100000
var lines = Array(repeating: UInt8(0), count: 4 * maxRocks + 1)

var rockCount = 0
var windCount = 0
var x: UInt8 = 0
var y = 0
let path = FileManager.default.currentDirectoryPath.appending("/input.txt")
let windChars = Array(try! String(contentsOfFile: path, encoding: String.Encoding.utf8))
var yMax = 0

let startTime = NSDate().timeIntervalSince1970

while rockCount < maxRocks {
  let shape = rockCount % Rock.Shape.allCases.count
  let rock = Rock(shape: Rock.Shape.allCases[shape])
  rockCount += 1
  y += 3
  x = 2
  // print("rockCount: " + String(rockCount))
  // print(rock.shape)

  while true {
    // print("can move left: " + String(rock.canMoveLeft(lines, x, y)))
    // print("can move right: " + String(rock.canMoveRight(lines, x, y)))
    // print("can move down: " + String(rock.canMoveDown(lines, x, y)))
    // print("x: " + String(x))
    // print("y: " + String(y))
    // print("wind: " + String(windChars[windCount]))

    if windChars[windCount] == ">" && rock.canMoveRight(lines, x, y) {
      x += 1
      // print("moved right to " + String(x))
    }
    if windChars[windCount] == "<" && rock.canMoveLeft(lines, x, y) {
      x -= 1
      // print("moved left to " + String(x))
    }
    windCount = (windCount + 1) % windChars.count

    if rock.canMoveDown(lines, x, y) {
      y -= 1
      // print("moved down to " + String(y))
    } else {
      // print("rock stopped")
      for (index, mask) in rock.masks.enumerated() {
        lines[y + index] = lines[y + index] | (mask >> x)
        // print(mask >> x)
        // print(lines[y + index])
      }
      
      y = max(y + Int(rock.height), yMax)
      yMax = y
      // print(yMax)
      // print(y)
      // print(lines.enumerated().first(where: { $0.element == 0 })!.offset)
      // y = lines.enumerated().first(where: { $0.element == 0 })!.offset
      // print("y is now: " + String(y))
      break
    }
  }
}

print(y)

let elapsed = NSDate().timeIntervalSince1970 - startTime
print((Double(1000000000000) / Double(maxRocks)) * elapsed)

// print(lines)
