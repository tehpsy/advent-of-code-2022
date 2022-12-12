#!/usr/bin/env swift
import Foundation

enum Direction: CaseIterable {
  case up, down, left, right
}

struct Point: Hashable {
  let x: Int
  let y: Int
}

class Node {
  let height: Int
  let point: Point
  let isOrigin: Bool
  let isDestination: Bool
  var nodes: [(Node, Cost)] = []
  var value: Int?
  init(height: Int, point: Point, isOrigin: Bool, isDestination: Bool) {
    self.height = height
    self.point = point
    self.isOrigin = isOrigin
    self.isDestination = isDestination
  }
}

class Queue {
  var nodes: [Node]
  let endNode: Node

  init(_ nodes: [Node], _ endNode: Node) {
    self.nodes = nodes.sorted { n1, n2 in n1.value != nil }
    self.endNode = endNode
  }

  func popFirst() -> Node? {
    let next = self.nodes.first
    // if next?.value == nil {
    //   return nil
    // }

    if !nodes.isEmpty {
      nodes.removeFirst()  
    }
    return next
  }

  func setValue(_ node: Node, _ value: Int) {
    node.value = value

    // nodes.sort { n1, n2 in
    //   if let v1 = n1.value, let v2 = n2.value {
    //     return v1 < v2
    //   }

    //   return n1.value != nil
    // }
    let sourceIndex = nodes.firstIndex(where: { $0 === node })!
    let destinationIndex = nodes.firstIndex(where: { $0.value == nil || $0.value! >= value })!
    
    nodes.remove(at: sourceIndex)
    nodes.insert(node, at: destinationIndex)
  }
}

typealias Cost = Int
typealias Nodes = Set<Point>

run("input.txt")

func createNode(char: Character, point: Point) -> Node {
  if char == "S" { return Node(height: 0, point: point, isOrigin: true, isDestination: false) }
  if char == "E" { return Node(height: 25, point: point, isOrigin: false, isDestination: true) }
  return Node(height: Int(char.asciiValue!) - 97, point: point, isOrigin: false, isDestination: false)
}

func connect(_ rows: [[Node]]) {
  rows.enumerated().forEach { (rowIndex, row) in
    row.enumerated().forEach { (colIndex, node) in
      if rowIndex > 0 {
        let toUp = rows[rowIndex - 1][colIndex]
        if toUp.height <= node.height + 1 {
          node.nodes.append((toUp, 1))
        }
      }

      if rowIndex < rows.count - 1 {
        let toDown = rows[rowIndex + 1][colIndex]
        if toDown.height <= node.height + 1 {
          node.nodes.append((toDown, 1))
        }
      }

      if colIndex > 0 {
        let toLeft = rows[rowIndex][colIndex - 1]
        if toLeft.height <= node.height + 1 {
          node.nodes.append((toLeft, 1))
        }
      }

      if colIndex < row.count - 1 {
        let toRight = rows[rowIndex][colIndex + 1]
        if toRight.height <= node.height + 1 {
          node.nodes.append((toRight, 1))
        }
      }
    }
  }
}

func process(_ nodes: [Node], _ endNode: Node) {
  let queue = Queue(nodes, endNode)
  var history = Set<Point>()
  while let node = queue.popFirst() {
    history.insert(node.point)
    node.nodes
      .filter { !history.contains($0.0.point) }
      .forEach { (nextNode, cost) in
        if node.value == nil { return }
        let newValue = cost + node.value!
        if nextNode.value == nil || newValue < nextNode.value! {
          queue.setValue(nextNode, node, newValue)
        }
      }

    if node === endNode { break }
  }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

func isOnLowestPlain(point: Point, rowStrings: [String]) -> Bool {
            return (point.y == 0 || rowStrings[point.y - 1][point.x] == "a") &&
              (point.y == rowStrings.count - 1 || rowStrings[point.y + 1][point.x] == "a") &&
              (point.x == 0 || rowStrings[point.y][point.x - 1] == "a") &&
              (point.x == rowStrings[point.y].count || rowStrings[point.y][point.x + 1] == "a")
}

func run(_ filename: String) {
  let path = FileManager.default.currentDirectoryPath.appending("/\(filename)")
  let rowStrings = try! String(contentsOfFile: path, encoding: String.Encoding.utf8).components(separatedBy: "\n")

    let nodes = rowStrings.enumerated().map { (rowIndex, line) in
      return line.enumerated().map{ createNode(char: $0.1, point: Point(x: $0.0, y: rowIndex)) }
    }
    let nodesFlat = nodes.flatMap { $0 }

    connect(nodes)

    // do { // part1
    //   let startNode = nodesFlat.first(where: { $0.isOrigin })!
    //   startNode.value = 0

    //   let endNode = nodesFlat.first(where: { $0.isDestination })!
    //   process(nodesFlat, endNode)
    //   print(endNode.value!)

    //   // let startNode = nodes[0][54]
    //   // nodes[0][0].value = 0
    //   // startNode.value = 0

    //   // let endNode = nodesFlat.first(where: { $0.isDestination })!
    //   // process(nodesFlat, endNode)
    //   // print(endNode.value)
    // }

  do { //part 2
    let startingPoints = rowStrings.enumerated()
      .map { (rowIndex, string) in
        return Array(string).enumerated()
          .filter { $0.1 == "a" || $0.1 == "S" }
          .filter { !isOnLowestPlain(point: Point(x: $0.0, y: rowIndex), rowStrings: rowStrings) }
          .map { $0.0 }
          .map { Point(x: $0, y: rowIndex) }
    }.flatMap { $0 }

    print(startingPoints.count)

    let endNode = nodesFlat.first(where: { $0.isDestination })!

    print(startingPoints
      .compactMap { point in
        print(point)
        nodesFlat.forEach { node in
          node.value = nil
        }
        let startNode = nodes[point.y][point.x]
        startNode.value = 0
        process(nodesFlat, endNode)
        print(endNode.value)
        return endNode.value
      }
      .sorted()
      .min())
  }
}  
