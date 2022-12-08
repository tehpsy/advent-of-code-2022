from __future__ import annotations
from enum import Enum
import math
import re
import functools

class File:
    def __init__(self, name: str, size: int):
        self.name = name
        self.size = int(size)

class Folder:
    def __init__(self, name: str, parent: Folder):
        self.name = name
        self.parent = parent
        self.contents = list()

class FileSystem:
    def __init__(self, input: str):
      lines = input.split('\n')
      lines = list(filter(lambda s: s != "$ ls", lines))
      lines.pop(0)      

      self.root = Folder("", None)
      curr = self.root

      for line in lines:
        dirMatch = re.search(r"dir (.+)", line)
        if dirMatch is not None:
          curr.contents.append(Folder(dirMatch.group(1), curr));
          continue

        fileMatch = re.search(r"(\d+) (.+)", line)
        if fileMatch is not None:
          curr.contents.append(File(fileMatch.group(2), fileMatch.group(1)));
          continue

        cdMatch = re.search(r"\$ cd (.+)", line)
        if cdMatch is not None:
          if cdMatch.group(1) == "..":
            curr = curr.parent
          else:
            curr = list(filter(lambda s: s.name == cdMatch.group(1), curr.contents))[0]
          continue

def size(node):
  if isinstance(node, File):
    return node.size
  return functools.reduce(lambda total, node: total + size(node), node.contents, 0)

def isFolder(node):
  return isinstance(node, Folder)

def dirsSmallerThan(node, max):
  if isinstance(node, File):
    return []

  return functools.reduce(
    lambda acc, node: acc + ([node] if size(node) < max else []) + dirsSmallerThan(node, max),
    list(filter(isFolder, node.contents)),
    []
  )

if __name__ == '__main__':
    with open('input.txt') as f:
      fileSystem = FileSystem(f.read())
      
      part1 = functools.reduce(
        lambda acc, folder: acc + size(folder),
        dirsSmallerThan(fileSystem.root, 1e5),
        0
      )
      print(f"Sum of dirs less than 100,000: {part1}")

      spaceToClear = size(fileSystem.root) - 7e7 + 3e7;
      part2 = size(list(filter(
        lambda x: size(x) >= spaceToClear,
        sorted(dirsSmallerThan(fileSystem.root, 100000000), key=lambda x: size(x))
      ))[0])
      print(f"Smallest dir for deletion: {part2}")