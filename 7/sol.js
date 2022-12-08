const fs = require("fs");
const input = process.argv[2];
const lines = fs
  .readFileSync(input, "utf-8")
  .split("\n")
  .filter((x) => x !== "$ ls")
  .slice(1);

const root = {
  name: "",
  contents: [],
};
let curr = root;

for (let line of lines) {
  const dirMatch = line.match(/dir (.+)/);
  if (dirMatch !== null) {
    if (curr.contents.filter((x) => x.name !== dirMatch[1])) {
      curr.contents.push({
        name: dirMatch[1],
        contents: [],
        parent: curr,
      });
    }
    continue;
  }

  const fileMatch = line.match(/(\d+) (.+)/);
  if (fileMatch !== null) {
    curr.contents.push({
      name: fileMatch[2],
      size: parseInt(fileMatch[1]),
    });
    continue;
  }

  const cdMatch = line.match(/\$ cd (.+)/);
  if (cdMatch !== null) {
    if (cdMatch[1] == "..") {
      curr = curr.parent;
    } else {
      curr = curr.contents.filter((x) => x.name == cdMatch[1])[0];
    }
  }
}

const size = (node) => {
  if (node["contents"] === undefined) {
    return node.size;
  }

  return node.contents.reduce((total, node) => {
    return total + size(node);
  }, 0);
};

const dirsSmallerThan = (node, max) => {
  if (node["contents"] === undefined) {
    return [];
  }

  return node.contents
    .filter((x) => x.contents !== undefined)
    .filter((x) => size(x) <= max)
    .concat(node.contents.map((x) => dirsSmallerThan(x, max)).flat());
};

const part1 = dirsSmallerThan(root, 100000).reduce((total, node) => {
  return total + size(node);
}, 0);
console.log(`Sum of dirs less than 100,000: ${part1}`);

const spaceToClear = size(root) - 7e7 + 3e7;
const part2 = dirsSmallerThan(root, 100000000)
  .sort(function (a, b) {
    return size(a) > size(b) ? 1 : -1;
  })
  .filter((x) => size(x) >= spaceToClear)
  .map((x) => size(x))[0];
console.log(`Smallest dir for deletion: ${part2}`);
