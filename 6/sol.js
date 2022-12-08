const fs = require("fs");
const input = process.argv[2];
const string = fs.readFileSync(input, "utf-8");

const isUnique = (string) => {
  return new Set(string).size == string.length;
};

const calculate = (string, messageSize) => {
  for (let i = messageSize - 1; i < string.length; i++) {
    if (isUnique(string.slice(i - messageSize + 1, i + 1))) {
      return i + 1;
    }
  }
  return -1;
};

console.log(calculate(string, 4));
console.log(calculate(string, 14));
