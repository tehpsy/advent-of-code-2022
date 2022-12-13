const assert = require("assert");
const fs = require("fs");

const compareArrayLengths = (a, b) => {
  if (a.length < b.length) {
    return -1;
  } else if (a.length > b.length) {
    return 1;
  } else {
    return 0;
  }
};

const sortInts = (a, b) => {
  if (a < b) {
    return -1;
  } else if (a > b) {
    return 1;
  } else {
    return 0;
  }
};

const sort = (a, b) => {
  const max = Math.min(a.length, b.length);
  for (let index = 0; index <= max; index++) {
    if (index == max) {
      return compareArrayLengths(a, b);
    }

    const left = a[index];
    const right = b[index];
    const [leftIsInteger, rightIsInteger] = [
      Number.isInteger(left),
      Number.isInteger(right),
    ];

    const result =
      leftIsInteger && rightIsInteger
        ? sortInts(left, right)
        : sort(leftIsInteger ? [left] : left, rightIsInteger ? [right] : right);

    if (result != 0) {
      return result;
    }
  }
};

assert.equal(-1, sort(JSON.parse("[1,1,3,1,1]"), JSON.parse("[1,1,5,1,1]")));
assert.equal(-1, sort(JSON.parse("[[1],[2,3,4]]"), JSON.parse("[[1],4]")));
assert.equal(-1, sort(JSON.parse("[[4,4],4,4]"), JSON.parse("[[4,4],4,4,4]")));
assert.equal(-1, sort(JSON.parse("[]"), JSON.parse("[3]")));
assert.equal(1, sort(JSON.parse("[9]"), JSON.parse("[[8,7,6]]")));
assert.equal(1, sort(JSON.parse("[7,7,7,7]"), JSON.parse("[7,7,7]")));
assert.equal(1, sort(JSON.parse("[[[]]]"), JSON.parse("[[]]")));
assert.equal(
  1,
  sort(
    JSON.parse("[1,[2,[3,[4,[5,6,7]]]],8,9]"),
    JSON.parse("[1,[2,[3,[4,[5,6,0]]]],8,9]")
  )
);

const pairs = fs
  .readFileSync("input.txt", "utf-8")
  .split("\n\n")
  .map((s) => s.split("\n"))
  .map((s) => s.map((t) => JSON.parse(t)));

const part1 = pairs.reduce((sum, pair, index) => {
  const res = sort(pair[0], pair[1]);
  const val = res == -1 ? index + 1 : 0;
  return sum + val;
}, 0);
console.log(part1);

const part2 = pairs
  .flat()
  .concat(JSON.parse("[[[2]]]"))
  .concat(JSON.parse("[[[6]]]"))
  .sort((a, b) => sort(a, b));

console.log(
  (part2.findIndex((obj) => JSON.stringify(obj) == "[[2]]") + 1) *
    (part2.findIndex((obj) => JSON.stringify(obj) == "[[6]]") + 1)
);
