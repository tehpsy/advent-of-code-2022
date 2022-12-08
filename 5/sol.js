const fs = require("fs");
const input = process.argv[2];

const data = fs.readFileSync(input, "utf-8").split("\n\n");
const topInstructions = data[0].split("\n");
const bottomInstructions = data[1].split("\n");
const initialStateString = topInstructions.slice(0, topInstructions.length - 1);
const numColumns = (initialStateString[0].length + 1) / 4;

const makeColumn = (index) => {
  return initialStateString
    .map((x) => x[4 * index + 1])
    .filter((x) => x !== " ")
    .reverse();
};

const makeColumns = () => {
  return [...Array(numColumns).keys()].map((x) => {
    return makeColumn(x);
  });
};

const getString = (columns) => {
  return columns
    .filter((x) => x.length !== 0)
    .map((x) => x[x.length - 1])
    .join("");
};

const parseInstruction = (instruction) => {
  const regex = /[^0-9]+(\d+)[^0-9]+(\d+)[^0-9]+(\d+)/;
  return instruction
    .match(regex)
    .slice(1, 4)
    .map((x) => parseInt(x));
};

const part1 = makeColumns();

for (let i = 0; i < bottomInstructions.length; i++) {
  const [numCrates, fromColumn, toColumn] = parseInstruction(
    bottomInstructions[i]
  );

  for (let move = 0; move < numCrates; move++) {
    const popped = part1[fromColumn - 1].pop();
    part1[toColumn - 1].push(popped);
  }
}

console.log(getString(part1));

const part2 = makeColumns();

for (let i = 0; i < bottomInstructions.length; i++) {
  const [numCrates, fromColumnIndex, toColumnIndex] = parseInstruction(
    bottomInstructions[i]
  );

  const fromColumn = part2[fromColumnIndex - 1];
  const toColumn = part2[toColumnIndex - 1];
  toColumn.push(...fromColumn.splice(fromColumn.length - numCrates, numCrates));
}

console.log(getString(part2));
