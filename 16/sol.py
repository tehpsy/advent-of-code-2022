from __future__ import annotations
from enum import Enum
import math
import re
import functools
import copy

class Node:
  def __init__(self, id: str, flow: int):
    self.distance_map = {}
    self.id = id
    self.flow = flow
    self.open = False
    self.neighbour_ids = list()
    # self.from_node = None
    self.value = None

def custom_index(it, f, default=-1):
    return next((i for i, e in enumerate(it) if f(e)), default)

class Queue:
  def sort(self, nodes):
    return sorted(nodes, key=functools.cmp_to_key(sort))
    # return sorted(nodes, key=lambda x: float('inf') if x is None else x)

  def __init__(self, node_map, end_node):
    self.nodes = self.sort(list(node_map.values()))
    self.end_node = end_node

  def set_value(self, node, value):
    node.value = value
    self.nodes = self.sort(self.nodes)
    
    # source_index = nodes.index(node)
    # dest_index = custom_index(self.nodes, lambda x: (x == None) or (x.value >= value))
    # self.nodes.remove(node)
    # self.nodes.insert(dest_index, node)

def create_node(line):
  match = re.search("([A-Z]{2,}).+=(\d{1,})", line)
  return (match[1], Node(match[1], int(match[2])))

def get_connection_ids(line):
  match = re.search("Valve ([A-Z]{1,}).+valves? (.+)", line)
  return (match[1], match[2].replace(" ", "").split(','))

def process(node_map, start_id, end_id):
  for key in node_map:
    node_map[key].value = None
  node_map[start_id].value = 0

  queue = Queue(node_map, node_map[end_id])
  history = set()
  node = queue.nodes.pop(0)
  while node != None:
    # print(f"process {node.id}")
    history.add(node.id)
    # print(f"history {history}")
    for next_id in node.neighbour_ids:
      # print(f"next_id {next_id}")
      # print(f"node value {node.value}")

      if next_id in history or node.value == None:
        # print(f"continue")
        continue

      new_value = node.value + 1
      # print(f"new value {new_value}")
      next_node = node_map[next_id]
      # print(f"next_node {next_node}")
      if next_node.value == None or new_value < next_node.value:
        # print(f"set value {new_value}")
        queue.set_value(next_node, new_value)

    # print(f"finished iterating neighbours")

    if node.id == queue.end_node.id:
      # print(f"got to end")
      # return node.value
      break


    node = queue.nodes.pop(0)

def sort(node1, node2):
  # print(node1.id)
  # print(node1.value)
  # print(node2.id)
  # print(node2.value)
  if node1.value is None and node2.value is None: return 0
  if node1.value is not None and node2.value is not None: return node1.value < node2.value
  if node1.value is not None: return -1
  return 1

def connect_nodes(node_map, connections):
  for id in connections:
    node_map[id].neighbour_ids = connections[id]

def populate_distances(node_map):
  for start_id in node_map:
    for end_id in node_map:
      if start_id == end_id: continue
      end_node = node_map[end_id]
      if (end_node.flow == 0): continue

      process(node_map, start_id, end_id)
      start_node = node_map[start_id]
      start_node.distance_map[end_id] = node_map[end_id].value

def paths(node_map, start_id, history, time_remaining):
  start_node = node_map[start_id]
  history.add(start_id)
  ret_val = list(start_id)

  for node_id in start_node.distance_map:
    node = node_map[node_id]
    distance = start_node.distance_map[node_id]
    if (node.open or node.flow == 0 or distance > time_remaining - 1): continue
    ret_val.append(paths(node_map, node_id, copy.deepcopy(history), time_remaining - distance))

  print(ret_val)
  return ret_val

# def trim(node_map):
#   for node_id in list(node_map.keys()):
#     node = node_map[node_id]
#     if (node.flow == 0):
#       del node_map[node_id]
    
def calc(start_node_id, node_map, history, time_left):
  start_node = node_map[start_node_id]
  node_val = start_node.flow * time_left
  history.add(start_node_id)
  print(f"start_node_id {start_node_id}")
  print(f"history {history}")
  sub_vals = list()
  print(f"node_val {node_val}")
  sub_vals.append(node_val)
  for node_id in start_node.distance_map:
    if (node_id in history): continue
    distance = start_node.distance_map[node_id]
    if (distance > time_left - 1): continue
    print(f"sub {node_id}")
    sub_val = calc(node_id, node_map, copy.deepcopy(history), time_left - distance - 1)
    sub_vals.append(node_val + sub_val)

  return max(sub_vals)

if __name__ == '__main__':
    with open('input.txt') as f:
      lines = f.read().split('\n')
      node_map = dict(map(create_node, lines))
      connect_nodes(node_map, dict(map(get_connection_ids, lines)))
      populate_distances(node_map) 
      # trim(node_map)
      print(node_map)
      # paths(node_map, "AA", set(), 30)
      print(calc("AA", node_map, set(), 5))
      
