#!/usr/bin/env swift
import Foundation

class Rock {
    let shape: Shape
    let width: UInt8
    let height: UInt8
    let masks: [UInt8]

    enum Shape: CaseIterable {
        case hline, plus, capl, vline, box
    }

    static let hline = Rock(shape: .hline)
    static let plus = Rock(shape: .plus)
    static let capl = Rock(shape: .capl)
    static let vline = Rock(shape: .vline)
    static let box = Rock(shape: .box)
    static let shapes = [hline, plus, capl, vline, box]

    init(shape: Shape) {
        self.shape = shape
        switch shape {
        case .hline: self.width = 4; self.height = 1
        case .plus: self.width = 3; self.height = 3
        case .capl: self.width = 3; self.height = 3
        case .vline: self.width = 1; self.height = 4
        case .box: self.width = 2; self.height = 2
        }
        switch shape {
        case .hline: self.masks = [0b1111000]
        case .plus: self.masks = [0b0100000, 0b1110000, 0b0100000]
        case .capl: self.masks = [0b1110000, 0b0010000, 0b0010000]
        case .vline: self.masks = [0b1000000, 0b1000000, 0b1000000, 0b1000000]
        case .box: self.masks = [0b1100000, 0b1100000]
        }
    }

    func canMoveDown(_ lines: inout [UInt8], _ x: inout UInt8, _ y: inout Int) -> Bool {
        if y == 0 { return false }
        let shift = 7 - width - x
        let nextLine = lines[y - 1]
        switch shape {
        case .hline: return nextLine & (0b1111 << shift) == 0
        case .plus: return (nextLine & (0b010 << shift) == 0) && (lines[y] & (0b101 << shift) == 0)
        case .capl: return (nextLine & (0b111 << shift) == 0)
        case .vline: return (nextLine & (0b1 << shift) == 0)
        case .box: return (nextLine & (0b11 << shift) == 0)
        }
    }

    func canMoveRight(_ lines: inout [UInt8], _ x: inout UInt8, _ y: inout Int) -> Bool {
        if 7 - width - x <= 0 { return false }
        let mask = UInt8(1 << (7 - 1 - width - x))
        switch shape {
        case .hline:
            return lines[y] & mask == 0
        case .plus:
            let maskShiftedLeftByOne = UInt8(1 << (7 - width - x))
            return
                (lines[y] & maskShiftedLeftByOne == 0) &&
                (lines[y+1] & mask == 0) &&
                (lines[y+2] & maskShiftedLeftByOne == 0)
        case .capl:
            return
                (lines[y] & mask == 0) &&
                (lines[y+1] & mask == 0) &&
                (lines[y+2] & mask == 0)
        case .vline:
            return
                (lines[y] & mask == 0) &&
                (lines[y+1] & mask == 0) &&
                (lines[y+2] & mask == 0) &&
                (lines[y+3] & mask == 0)
        case .box:
            return
                (lines[y] & mask == 0) &&
                (lines[y+1] & mask == 0)
        }
    }

    func canMoveLeft(_ lines: inout [UInt8], _ x: inout UInt8, _ y: inout Int) -> Bool {
        if x == 0 { return false }
        let mask = UInt8(1 << (7 - x))
        switch shape {
        case .hline:
            return lines[y] & mask == 0
        case .plus:
            let maskShiftedRightByOne = UInt8(1 << (7 - 1 - x))
            return
                (lines[y] & maskShiftedRightByOne == 0) &&
                (lines[y+1] & mask == 0) &&
                (lines[y+2] & maskShiftedRightByOne == 0)
        case .capl:
            let maskShiftedRightByTwo = UInt8(1 << (7 - 2 - x))
            return
                (lines[y] & mask == 0) &&
                (lines[y+1] & maskShiftedRightByTwo == 0) &&
                (lines[y+2] & maskShiftedRightByTwo == 0)
        case .vline:
            return
                (lines[y] & mask == 0) &&
                (lines[y+1] & mask == 0) &&
                (lines[y+2] & mask == 0) &&
                (lines[y+3] & mask == 0)
        case .box:
            return
                (lines[y] & mask == 0) &&
                (lines[y+1] & mask == 0)
        }
    }
}

let maxRocks = 100000000
var lines = Array(repeating: UInt8(0), count: 4 * maxRocks + 1)

var rockCount = 0
var windCounter = 0
var x: UInt8 = 0
var y = 0
let windValues = ">>>><<<><<<>><<>>>><>>><<<>><<<>><<<<>>>><>>><<>><<<>>>><<<<>>><<><>>><<<<>>>><>><<><<<><<<><<>><><><<<<>>><<<<><<>>>><<>>>><>><<<<>><<<>><<<<>>><<<>>>><<>>><>><>>><>><<>>>><<><><<<>>><<><><<<<>><<<>>><<<<>>>><<><<>>><<<>>><<<><<<<>>>><<<>><><<<>>><<<>>><<<<><<<>>>><<>>><>>><<<<>>>><>><<<<>><<<>>>><<>><>>>><<<>>><<>><<<>>>><>>>><><<>>>><<<>><<>><<>>>><<<>>><<>>><<<<>>><<<<>>>><<<<>>>><>><<<>>><<>><>>><>>><<>>><>>><<<>>><<<<>><<><<<><>>>><<<><>>>><<<<>>><<<<>><><<<<>>><<><<<<>>><<<<>><>><>>><<<><<<<>>>><><><<<>><<<<>><<<>><<<><<<<>>>><<<<>>><<<>>><>><<<<><<<>><<<>><>><<<<><><>>><<>>>><>>><>>><<<<>><<>><<>><<<>><<><<<<>><><<<<>><<>>>><<>>>><>>><<<>><<<<>><<<>>>><<<<>><<<<>>><<>>>><>>><<<<>>><<<<><<><<<><<<<>><<<>><<<><<<>>><<<<>><<<>>><><<>>><>>>><<<<>>>><<<>>><<>><><>>><<<><<>><>><<>>>><<<<><<>><<<<><<>>><<<<>><<<>>><<<>>>><>><<><<<><>><<<>>>><<<<>>><><<<<><<><<<>><<<<>><<<>><>>><<><<><<>>>><<>>>><<>>>><><<>>>><<<<>>><<<>>><<<>>><<<<>>><<<>><<<<><><><<<>><<<<>>>><<<<>>>><<<>>><<>>>><>>>><<<<>><<<><<<>>>><><><<><<<>>><<>>>><>>><>>><<>><>>>><<<>><><<<><<<<>>><<<<><><><>>><>><>>>><>>>><<<<>><<<>>><<<>>>><<<>><<>>>><<<><<<<>><<><<<>>>><<<<>>><><>>><>>>><<<<>><<><<<>>><<>>><<>><<><<>><>>><<<>><<<<>><>>><<><<>><<<<>><<<>><>>>><<<>>><<>><<><>>><<<<>>>><<<<>><<<>>>><><<>><<>>><><<<<>>>><<<<>><>>>><<<>>><<<>>>><<<<>><<><<<<>><><<>>><<<<>>>><<<<>>><<><<<>>><<<<>>><<<<><<<<>>>><<>>>><<>>><<>><<<<><<<>><<<>>>><<<<>>><<<<><>>>><<<<>>>><<<><<<>>>><<>>><<<<>>><<<<><<<>><<<<><>>><>>><<<<>>><>><<>>>><<<>><<><<<>>>><<<>>>><<<>>><<<<>>>><<>>><<<><<<<>>><<<>><<<<><><>><<>>>><<>><<><<>>>><<<>>>><<<<><>><>>><<>>><><<<>>>><<>><<><<<<>>>><<<>>><<<<>>>><<<>><<<<><<<<>><<><>>><>><<>>>><<<<>>>><<<>>><><<><<><>>>><<>>>><<<><>>><<<>><<<<>>><><<<><<>>>><><<>>><<<<>><<>>><<>>>><<<<>>>><<>>><><>>>><<<<>>><<<<>>><<<<>>>><<<>><>>><<<<><<<>><<<<>>><>><<>><<<<><<<><<>>><>>><<<>><<<>>><<>><<><>><<<>>>><>>><<<<>><<>>>><<<>>><<><<<>>>><<<><<<>>>><<<<>>><>>><>><<<>>>><<<<>>><<<>>>><<>><<<<>>>><>><>>><<<>>>><>>>><<>><<<><><<>>><<<>>>><>>>><>>><<><<<<>>>><<<>>>><<<>>><<<<>>><>>>><<<>>>><<<><<<>><<<<><<<><<<<><<<>>>><>><>><<<>><<<><<<><><<<>>><<>>>><<<<>>>><<>>>><>><<<>>><<><<<<><<<<>>>><<>>><<<><>>><>>><<<>>><>><<<<><<<<>>>><<>>>><>><<<<><><><<><<>>>><<>><>><>>>><<>>>><<<<>>>><>><>>><<<>>><<>><<<>>><><<<><<<>><<><<>>>><>>>><<>>>><><<<>>>><<<>>>><<<>>><<>>>><<>>>><<<>>><<<<>>>><<<<>><>>>><<>>><<<>>><<>>>><<<<>><<<>><<><>>>><<<>>><<>>>><<<<>>>><<>><<<>>><>><>><>>><><<>><<<>><<><<>>><>>>><<><>>><<<<><<<<>><>><<<<>>><<<>>>><>><<<>>><<<<>>>><<<>>>><<>><<><<<>>><><>><>><>>>><><<<>>><<>>>><<<<>><><<>>>><<<>>><<>><<<>><<<><<>><<>>><<>>><>><<>>>><<><<<<><<<<>>><<<<>>>><<>>><<>><<<><<<><<<>>><<<<>><>>><<>>><<>>>><<>>>><<>>>><<<>><><<<<><>><<><<<>><<<<>>>><<<<>>>><<<><<<>><<<>>><>><>>>><<<<>>><<<>>><>>>><<<>>>><>><<<><<><<<>>>><<<>>><>>><<<>>><<<><<>>>><<<>><<><<>><<<><<<<>>><<<>><<>>><<<<>><>>>><<>>><<><<<<>><><<>>>><<<><<>><<>><<>>><<<<>>>><<<<>>><<<><<<<>>><<<>>><>>><<>><<<<><>>><<<<>><<<<>>><<><<<<>>><<<>>><<<<>><<<<>>>><><><<>>>><>><<<><><<<<>>><><<<<>>>><><><<<>>><>><<<<><>><<<<>>>><<>>>><<<>>><>>><>>><><>>>><<>><<<>>>><<<>>>><<<>>>><<<<>>>><<<><>><<<<>>>><<><<<<><<<>>>><<><>>>><<><<<>>>><><<<><<>><<<<>><<>><>><<<>><<<>>><>>>><>>>><<><<<>><<<>>>><<<<><<<>>><>><<>>><<>>><<<>>><<>>><>><<>>><<<<><<>><<<<>><<<>><>>>><>><><<<>><<<>><>>><<<<><<<>><<>><<<<>>>><<<<>>><>>><<<>>>><<<>>>><<<>><<<>>>><<<>><<<>><<<<>>><><<>><<<<>><>><<>><<<>><<<>>><<<<>>>><<<><<<<>>>><>>><<<<>>><<>>>><<<<>>><>>>><<<>><>>>><<><<>>><>>>><<>>>><<<>><<<><<<<>>><<<>>><<<>>>><<><>>>><<<>>>><<<<>>>><>>><<<><>><<>>>><<<<>>><>>><<<<>>><<<<>><<<<>><<<>><<>>><<<>>>><><<>>><>>>><<>>><<<<><<><<>>>><<<<>><<<<>>>><<<>><<><<>><<<<>>>><>><<<<>><<<>>><>>>><<<>>>><<><<<<><<<>><<<>>><<<<>>><<<>>><<<>>>><<<>>><><<<>>><>><<<>>><<>>><><<<>>>><<<<>>>><<<><<<<>>><<><<<>>><<<<>><<<>><>>>><<<>><<><<<<>>>><>><<<<>><<<>>><<>>><<<>>><<<>>><<<<>>><<<<><>>><>><><<<<>><<<>>><<<<><<<>>><<>><>><<>>>><<>>>><>>>><<><<>><>>>><<><<<<><<<<>>><>><<>>>><<<<>>><>>><<<<><<>><<><<<>>>><<>>>><<>>>><<<<><<>><>><><<<>><<<<>>><<<><<<>><>><<<>><><>>>><><<<>>><<<<><<<<>>><<<>>>><>>><<>>><<>>>><>>>><><<<<>>>><<<>>>><<<>><<>>><<><<<>>>><<<>>><<<><><>><<<>>><<<>>>><<>><<<<>><><<<<>><<<>><<<<><<>>>><<>>><<>><<>>>><<>>><<>>><<<<>>>><>>><<>>><<<>>><>>>><<<><<<<>><<><<<<>><<<>><<<>>><<<<>><>><<>><<<>>>><<>>><<<>><<>>>><<<<>><<>>>><<<>>><<<<><<<>>>><<<>>><<<>><<><>>>><<<<><<<<>>><<<<>>>><>>><><>>>><<<>>><<<<>>>><>>>><<<>>>><<><<<<>>><<>><<<<>><<<><<><<<>><<<>>><<<>>><<>>>><<<<>>><<>>><<>><><<<<>>><<<<>>>><><<><>><<<>>>><<<><<>>><<>>>><<<>>><>>>><>><>>><<<><>><<<<>>><>>><>><>><<<<>>><<>>><>>>><<<>><<>>><<<>><<<>><<<<><<>>>><>>><>><<<<>>>><><<<><<><<>>><<><<<>>>><<>><<>>><<<>>>><<>>>><<><<>>><>>>><<>><<<>><><>><<<>>>><<>><>><<>>>><<<<>>>><<<<>>>><<<><<>><<<<>>><<<<>>><<<<>>><<<<>><<<<>>><<<>><<>>><<<<>>><<>>>><<<>><>><>>><>>>><>><<<<><><<>>>><>>><<<>>>><<<>>>><<>>><<<<>><>>><<<<>>>><><<<<><<>><>>>><>>><<>>>><><<><<<<>><<<><><<<<>><<>>>><<<<>><>><<>><<>><<><<<>>><><>>><<<>>>><<<<><>>>><><>>>><<<<>>><<>><<>><<<<>>>><<>>>><<<<>>>><><<<><<>>><<<<>>>><<>>>><>>>><<<<>><<<>><<>>><<<<>>>><<<<>>>><<<<>><<<<><>>>><>>><<<<><<<<>>>><<<><<<<><<>>><>>>><<<>>><<<<>>><<>>>><<>>><<<<><<<<>>>><>>>><<<>><<<<>><>>>><>>><<<<>>>><>>>><<>>><<<>>>><>><<<<>>><<>>><<><<<><<<<>><<<<>><<><<<<><<<>>><<>>>><<<><<<<>>><<>><<<<>>>><>><<>>><<<<>>>><<<>>>><><>>><>>><<<<><>><<>>>><>>>><<>>>><<<<><>>>><<<>>>><<<<>>>><>><<<<><<<<>><<<>><<>>><<><<>>><<>><>>>><><<<>>>><<<<><<<>><<<<><<><>>><<>>>><<><<<<>><><<<>>><<<<>>><<<<><<<<>><>>>><<><<<>>><<>><<<<>>>><>>>><>>>><>><<<<><<<>>>><<<>><<<>>>><>>>><<<<>>>><<<>>>><<><<><<>><<><<<>>><<<<>><>>><<><<<<>><<<<>>>><<<<>>><<>>>><>><<<<>><><<<<>><<>><<<<>>>><<>>>><<<<>><>>><<<>><<><>>><<>><<<><<<<>>><>>>><<>><<>>><<>><<><<>>><<<<><<>>>><<>>>><<>><>>>><<>><>><>><<<<>>>><>>>><<<>>>><<<<>>>><<><<>>><><<>>><>>><><<<>><<<<>>><<<><<<<>>>><<<>>>><><>>><<<><<<>>><<<<><<<<>>><<>><<>><><<>>><<<><<<<>><>><<><<<>>><<>>><<>>>><>><>>><<<>><>>>><<<<><<<<>>>><><>>><>><><<<>>>><<<<>><<>><><>>><<<><<><<>>>><<<>>><>>>><<<<>>>><>><<<<><>>>><>>>><<<>>><<><<>>>><<>>><<<>>><<<>>><><<<>><<<<>>>><<>>>><<<<>>><<<>>><<<<><<>><>>>><>>>><<><<<<>><<<<>>><<<<>>><>>><><<>><<<><<<><<<>><<>>>><>><>>><><<<><<><>>>><<<<><<<>>>><><<><>>><<<<>>><<<>><<<<>>><<>>>><>>><>><<>><<<<>><<><<>><>>>><<>>><<<>><><<>>>><<>>><<>><<>><<<>>><<<>>>><<<<><<<<>>><<<>><>>><<<>><<<>>><<<>>>><<<<>><<<<>>><<><<<<>>><><<>>>><<<><<<<>>><<<<>>><<<>>>><<><<<<>>>><>>><<><<<<>>><>>>><<<<>>><><<<>>><>>><<>>>><<<>>><<<<>><<<<>><<>>><<<<>><>>>><<<<>>>><<<<>>><>><<>>>><<<<>>>><<<<>><<<>>><<<>>><>>><>>>><>><><>><<><<><><<>><>>><<<><<<>><<<>><<<>>><>><<>>>><<>><<<>>>><><<<><<>><<<<><<<><<>>>><>><<><<>><<>>><<<><>>><<<>>>><<<<>><<>>>><<<>>>><><>>><><<<<><<>>><>><<<><<<>>>><><>>>><>>>><<<<>>><><<<>><<<>>><<>>><<<><<<<>><<>>>><<<>>>><<>><<><<<>>>><<>>><<<>><><<><<<<>>><><>>>><<>><><<<<>>>><>>>><<<<><<>>>><<>>>><<<<><>><<<>>>><<<<><<<<>>><<<>><<<<><<<>>><>>>><<<<>>><<<>>><<>>><<>><<<><<<>>><<<>>>><<<><<<<>>><<<>><>>>><>><<<<>>>><><<<>><<>>>><<<<>>><><>><<>><>>><<<>>><>>>><<<<><><<<<>><<>>>><<<<>>><<><<<<>>><<<>>>><<<<><>>><>><><<>><<<><>>><<<><><<>><<<>><<<<><<<>>>><><><<<<><<<>>>><>>>><<>>><<>>><<<>><<>>><<<><<>>>><><<><><>>><<<>><<<<><<<><<>><<><<<>>>><<>>>><<><>>>><<>>><<<<><<<<><<<<>><<<<>>>><<><<<><>>><<<<>>><<<>><<<<>>>><<<>>>><<<>><<><><><><<><<<<><<<>><<<>><<<>><>><<<<>><<>>><<><<>>><<<><<<<>><<<>>>><<>>>><>>><<><>><<<<>>><>><<<>>><<<><<>>>><<<<>>><<<<>>><<<<>>><>>><>>><>><<>>>><<<><<<><<<>><<<>><<<>><<<>>><>>><<>>><<<<><>>><<<<><<<>>><<<>>>><<<<>>><<>><>>><>>><>><<<<>>><<<<><><<<><<>><<<>>>><<<>>><<><>>><<>><>>><<<>>>><<<>>>><<<><>>>><<><<><<<<>>><<<<><<><<>>>><<<>><<<<>>>><<<<>>>><><<<<>><<>>><<<<>>>><<>>><<<>>><>>><>>>><<<>><><<>>><<<>>><<><<<><<<<><<<<><>><<>>><<<<>>>><<<><<><<<<>>>><<<>><<<<><<>><<<><<<>><<<>>>><<<<>>><<<>><<<<><<<>>><<<<>><<>>>><<<>><<><<<<><<<>><>>><>>><<>>>><<<<><<<><<<<>><<<<>>>><><>>><<>>>><<>>><>><<>>><<<>>>><<<>><>>><<>><<><<<>>><<<><<<>>>><<>>>><<<<>>><<>>>><<<>>>><<><>>><<>>><<>>><<<>>><><<><<<<>><<>><><<<>>>><<<>>><<<><><<<<><<<<><<>>>><>>><>>><<<>>><<>>><<<<>>>><<<><<><<<<><<<><<<<>>><>>>><>>>><<<>>><<<<>>>><<<>><<>><<>>><<>><><<>>><<<>>><<>><<<<>><<<>>><<>><<<<>><>><><>>><><<<<>>>><<>>>><<<>><><<<<>><<<<><<<>><<<<>><><<<><<>><<<>>>><>><<<>>><><<<<>><<>><<>>>><<>><<<<>><<<<>><<>><<<<><<<<>>><<<><<<<>>>><<><>><<<<><>>><<<<><<><<<<>><>><<><<<>>>><<<<>>>><<<<><<>>>><<<<><<<><<>><>><<<>>>><>><<>>><<<<><<>>><<><<<<>><<><<<>><>><<<>>>><<<<><<<<>><>><<<>><<<>>><<>>><<<<>>><<>>><<<<><<<<>><<<<>>><<<>><><<<><>><<<<><<<<>><<<<><<<>>>><<><<><>>><<<<>><<<<>>>><>>><>><<>><<>><<<<>><>>>><<<<>>>><<<>>>><<>><><<<<>>><<<<>>>><<<>>><<><>>><<<<>>>><<<<>>>><<><>>>><<<<><<<><<<<>>><<<<><<<>>>><<<<>><<<>>><<<>>>><<><<><>>>><>>>><<<<>><>><<>>><<<><><<>>><<<>><<>>><<<><<<>>><<>>><<>>>><<<><>>>><><<<>>><>><<<>><<><<<>>><>>><<<<>>>><<<>>><>>><<>><<<>>><>><<>><>>>><<<<><<<>>>><><<<<><<<<><<<<><<>>>><<>>>><<>><<<<>><<<>>><<><<<>>>><<<<>>>><<<>>>><<<><<<>>>><<>>>><<<<>><>><<>>>><>>>><<<>><<<>><>>>><<<>>><>><>>>><>><<<<>><<>>><>><<>>><<<<>><><<<>><<<<>>><>>>><<<<>>><<<><<<>><<><<>>>><>>><<<><<>><<<><<>>>><><<<<>><<<>>><<>>><>>>><>>><>>>><<<><>><<<>>>><>>><<<>>><<><<>><<<<><<><>><<<>>><<<>>><<<>>>><<<><<<<>>><<<<><<<><<<>>>><<>>><>>>><<<>><<>>>><<><<<<><<<<>><<>>><<><<>><<><>>>><>><<<<>>><<<<>>>><<<><<<<>>>><>>>><<<><<>><<>>><<<<>><<>><<>>>><>>><>>><<>><>>><<>><<<<>>><><<>>><<<<>><<<>>><<<>><><<<<>><<<<>>><<<>><<<>>><>>>><<<>>>><<>>><>><>><<<<>>>><<<>>>><<>><<<<>>><<<<>>><><>><<><>>>><<<<>><<>>><>>>><<<><<<<>>>><>>><<<<>>>><<><<<<>>><<<<>>><<<<>>>><><<>><<>><<<>><<><<<>>>><<<>>>><<>><<<<>><>><<<>>>><<<<><<<>>>><<<>>><<<<>>>><<>>>><<<><<<<>>>><><>><<>>><<<<><><<>>>><<<>>>><<<><<<<>><<<<>>><<<><<<>><<><<<>>>><<>>><>><>><<>>>><><<><<<<>>><<>>>><<<<>>><<<<><><<<><<<>>><<><<>>>><<<>>><<<>><<>>>><<<<>>>><>><<>>><<>>>><<<><<>>>><<<>>>><<<<>>>><<<<><<<<><<<><<<<>>>><<>>><<>>><<>><<><<>>><<<>>>><>><<<><<>>>><<>><<><<<>>>><>><>>>><<>>>><><>><<<<><<<<>>><<<><<>><<>>><<<<>>>><>>>><<><<<>>><<<>>>><<>>><<>><<>"
let windCount = windValues.count
let windToRight = Array(windValues).map { $0 == ">" }
var yMax = 0

let startTime = NSDate().timeIntervalSince1970

while rockCount < maxRocks {
    let rock = Rock.shapes[rockCount % 5]
    rockCount += 1
    y += 3
    x = 2

    while true {
        if windToRight[windCounter] && rock.canMoveRight(&lines, &x, &y) {
            x += 1
        }
        if !windToRight[windCounter] && rock.canMoveLeft(&lines, &x, &y) {
            x -= 1
        }
        windCounter = (windCounter + 1) % windCount

        if rock.canMoveDown(&lines, &x, &y) {
            y -= 1
        } else {
            for (index, mask) in rock.masks.enumerated() {
                lines[y + index] = lines[y + index] | (mask >> x)
            }

            y = max(y + Int(rock.height), yMax)
            yMax = y
            break
        }
    }
}

print(yMax)

let elapsed = NSDate().timeIntervalSince1970 - startTime
print((Double(1000000000000) / Double(maxRocks)) * elapsed / 86400)
