const fs = require("fs");
const input = process.argv[2];

const data = fs
  .readFileSync(input, "utf-8")
  .split("\n")
  .map((x) => x.match(/(\d+)-(\d+),(\d+)-(\d+)/))
  .map((x) => x.slice(1, 5))
  .map((x) => x.map((y) => parseInt(y)));

const part1 = data.filter(
  (x) => (x[2] >= x[0] && x[3] <= x[1]) || (x[0] >= x[2] && x[1] <= x[3])
).length;

console.log(part1);

const part2 = data.filter((x) => x[2] <= x[1] && x[0] <= x[3]).length;

console.log(part2);
