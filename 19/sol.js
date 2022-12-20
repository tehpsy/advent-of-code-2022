function mod(n, m) {
  return ((n % m) + m) % m;
}

const originalVals = require("fs")
  .readFileSync("input.txt", "utf-8")
  .split("\n")
  .map((s) => parseInt(s) * 811589153);

const indexMap = originalVals.reduce((accumulator, _, currentIndex) => {
    accumulator[String(currentIndex)] = currentIndex;
    return accumulator;
  },
  {}
);

const arr = JSON.parse(JSON.stringify(originalVals));
for (let i = 0 ; i < 10; i++) {
  for (const [index, val] of originalVals.entries()) {
    const currentIndex = indexMap[index];
    let newIndexUnwrapped = (currentIndex + val);
    // if (newIndexUnwrapped < 0) {
    //   while (newIndexUnwrapped < 0) {
    //     newIndexUnwrapped += originalVals.length;
    //   }
    //   newIndexUnwrapped -= 1;
    // }

    // if (newIndexUnwrapped >= originalVals.length) {
    //   while (newIndexUnwrapped >= originalVals.length) {
    //     newIndexUnwrapped -= originalVals.length;
    //   }
    //   newIndexUnwrapped += 1;
    // }

    // if (newIndexUnwrapped == 0 && val != 0) {
    //   newIndexUnwrapped = originalVals.length - 1;
    // }
    //  else if (newIndexUnwrapped == originalVals.length - 1 && val != 0) {
    //   newIndexUnwrapped = 0;
    // }

    const newIndex = mod(newIndexUnwrapped, originalVals.length - 1);
    // console.log(`newIndexUnwrapped: ${newIndexUnwrapped}`);
    // console.log(`index: ${index}`);
    // console.log(`val: ${val}`);
    // console.log(`currentIndex: ${currentIndex}`);
    // console.log(`newIndex: ${newIndex}`);
    arr.splice(currentIndex, 1);
    arr.splice(newIndex, 0, val);
    // indexMap[index] = currentIndex;
    // console.log(arr);
    
    if (currentIndex < newIndex) {
      // console.log("move forwards");

      // console.log(Object.entries(indexMap))
      for (const [k, v] of Object.entries(indexMap)) {
        if (v > currentIndex && v <= newIndex) {
          // console.log(k);
          // console.log(v);
          // console.log(v - 1);
          indexMap[k] = v - 1;
        }
      }

      indexMap[index] = newIndex;

      // console.log(indexMap);

    } else if (currentIndex > newIndex) {
      // console.log("move backwards");

      for (const [k, v] of Object.entries(indexMap)) {
        if (v >= newIndex && v < currentIndex) {
          // console.log(k);
          // console.log(v);
          // console.log(v + 1);
          indexMap[k] = v + 1;
        }
      }

      indexMap[index] = newIndex;

      // console.log(indexMap);
    }
  }
}

const originalIndexOfZero = originalVals.findIndex((v) => v == 0);
const currentIndexOfZero = indexMap[originalIndexOfZero];

console.log(currentIndexOfZero)

const part1 = [1000, 2000, 3000].reduce((accumulator, currentValue) => {
  return accumulator += arr[mod(currentValue + currentIndexOfZero, arr.length)];
}, 0);

console.log(part1);

