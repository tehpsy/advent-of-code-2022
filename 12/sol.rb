require 'set'

module Direction
  UP = 1
  DOWN = 2
  LEFT = 3
  RIGHT = 4
end

class Point
  attr_accessor :x
  attr_accessor :y
  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Node
  attr_accessor :height
  attr_accessor :point
  attr_accessor :character
  attr_accessor :nodes
  attr_accessor :value
  def initialize(point, character)
    if character == "S" 
      @height = 0
    elsif character == "E" 
      @height = 25
    else
      @height = character.ord - 97
    end
    @point = point
    @character = character
    @nodes = []
    @value = nil
  end
end

class Queue
  attr_accessor :nodes
  attr_accessor :end_node
  def initialize(nodes)
    @nodes = deep_copy(nodes).sort { |a, b| a.value == nil ? 1 : 0 }
    @end_node = @nodes.find {|n| n.character == "E" }
  end

  def set_value(node, value)
    node.value = value
    source_index = @nodes.index { |n| n.equal?(node) }
    dest_index = @nodes.index { |n| n.value == nil || n.value >= value }
    @nodes.insert(dest_index, @nodes.delete_at(source_index))
  end
end

def build_graph(path)
  lines = File.readlines(path, chomp: true)
  rows = lines.map.with_index { |string, row_index| 
    string.gsub(/\n/, "").chars.map.with_index { |character, col_index| 
      Node.new(Point.new(col_index, row_index), character) 
    }
  }
  connect(rows)
  return rows
end

def connected_node(node, row_index, col_index, nodes)
  neighbour = nodes[row_index][col_index]
  return (neighbour.height <= node.height + 1) ? neighbour : nil
end

def get_node(node, direction, nodes)
  row_count = nodes.length
  col_count = nodes[0].length
  col_index = node.point.x
  row_index = node.point.y

  if direction == Direction::UP && row_index > 0 
    return connected_node(node, row_index - 1, col_index, nodes)
  end

  if direction == Direction::DOWN && row_index < row_count - 1
    return connected_node(node, row_index + 1, col_index, nodes)
  end

  if direction == Direction::LEFT && col_index > 0 
    return connected_node(node, row_index, col_index - 1, nodes)
  end

  if direction == Direction::RIGHT && col_index < col_count - 1
    return connected_node(node, row_index, col_index + 1, nodes)
  end

  return nil
end

def connect_neighbour(node, direction, nodes) 
  neighbour = get_node(node, direction, nodes)
  if neighbour != nil 
    node.nodes.push(neighbour)
  end
end

def connect(rows)
  rows.each.with_index { |row, row_index| 
    row.each.with_index { |node, col_index| 
      connect_neighbour(node, Direction::UP, rows)
      connect_neighbour(node, Direction::DOWN, rows)
      connect_neighbour(node, Direction::LEFT, rows)
      connect_neighbour(node, Direction::RIGHT, rows)
    }
  }
end

def deep_copy(arr)
  return Marshal.load(Marshal.dump(arr))
end

def process(nodes_list)
  queue = Queue.new(nodes_list)
  history = Set.new
  node = queue.nodes.shift()
  while node != nil 
    history << node.point
    node.nodes
      .select {|node| !history.include?(node.point) }
      .each {|next_node| 
        next if node.value == nil

        new_value = node.value + 1
        if next_node.value == nil || new_value < next_node.value
          queue.set_value(next_node, new_value)
        end
      }

    if node.equal?(queue.end_node)
      return node.value
      break
    end

    node = queue.nodes.shift()
  end
end

def get_min(nodes, start_nodes)
  start_nodes
    .map { |n|
      nodes.each { |node| node.value = nil }
      n.value = 0
      val = process(nodes)
      puts val
      val
  }
  .select { |val| val != nil }
  .min()
end

def main()
  graph = build_graph('./input.txt')
  nodes = graph.flatten

  part1_starting_nodes = nodes.select { |n| n.character === "S" }
  puts "Part 1: #{get_min(nodes, part1_starting_nodes)}"

  part2_starting_nodes = nodes.select { |n| n.character === "a" || n.character === "S" }
  puts "Part 2: #{get_min(nodes, part2_starting_nodes)}"
end

main()