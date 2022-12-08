const fs = require("fs");
const input = process.argv[2];
const lines = fs
  .readFileSync(input, "utf-8")
  .split("\n")
  .map((x) => x.split(""))
  .map((x) => x.map((y) => parseInt(y)));

const numRows = lines.length;
const numColumns = lines[0].length;

const adjacentTo = (x, y) => {
  return {
    left: lines[y].slice(0, x),
    right: lines[y].slice(x + 1, numColumns),
    up: lines.slice(0, y).map((line) => line[x]),
    down: lines.slice(y + 1, numRows).map((line) => line[x]),
  };
};

const isVisible = (x, y) => {
  const height = lines[y][x];
  const adjacent = adjacentTo(x, y);
  return (
    adjacent.left.every((element) => element < height) ||
    adjacent.right.every((element) => element < height) ||
    adjacent.up.every((element) => element < height) ||
    adjacent.down.every((element) => element < height)
  );
};

const scenicScore = (x, y) => {
  const height = lines[y][x];
  const adjacent = adjacentTo(x, y);

  const blocking = (element) => element >= height;
  const foundIndexLeft = adjacent.left.reverse().findIndex(blocking);
  const foundIndexRight = adjacent.right.findIndex(blocking);
  const foundIndexUp = adjacent.up.reverse().findIndex(blocking);
  const foundIndexDown = adjacent.down.findIndex(blocking);
  const distanceLeft = foundIndexLeft == -1 ? x : foundIndexLeft + 1;
  const distanceRight =
    foundIndexRight == -1 ? numColumns - x - 1 : foundIndexRight + 1;
  const distanceUp = foundIndexUp == -1 ? y : foundIndexUp + 1;
  const distanceDown =
    foundIndexDown == -1 ? numRows - y - 1 : foundIndexDown + 1;

  return distanceLeft * distanceRight * distanceUp * distanceDown;
};

let numVisibleTrees = 0;
let highestScenicScore = 0;
for (const [rowIndex, row] of lines.entries()) {
  for (const [colIndex, _] of row.entries()) {
    if (isVisible(colIndex, rowIndex)) {
      numVisibleTrees++;
      highestScenicScore = Math.max(
        highestScenicScore,
        scenicScore(colIndex, rowIndex)
      );
    }
  }
}
console.log(`Count of visible trees: ${numVisibleTrees}`);
console.log(`Highest scenic score: ${highestScenicScore}`);
