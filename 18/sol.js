function hash(a, b, c) {
  return a * 100000 + b * 1000 + c
}

const countAllFaces = (points) => {
  const blocks = new Set();

  return points.reduce(
    (accumulator, currentValue) => {
      accumulator += 6
      const xPos = hash(currentValue[0] + 1, currentValue[1], currentValue[2]);
      const xNeg = hash(currentValue[0] - 1, currentValue[1], currentValue[2]);
      const yPos = hash(currentValue[0], currentValue[1] + 1, currentValue[2]);
      const yNeg = hash(currentValue[0], currentValue[1] - 1, currentValue[2]);
      const zPos = hash(currentValue[0], currentValue[1], currentValue[2] + 1);
      const zNeg = hash(currentValue[0], currentValue[1], currentValue[2] - 1);
      if (blocks.has(xPos)) { accumulator -= 2; } 
      if (blocks.has(xNeg)) { accumulator -= 2; } 
      if (blocks.has(yPos)) { accumulator -= 2; } 
      if (blocks.has(yNeg)) { accumulator -= 2; } 
      if (blocks.has(zPos)) { accumulator -= 2; } 
      if (blocks.has(zNeg)) { accumulator -= 2; } 
      blocks.add(hash(...currentValue));
      return accumulator;
    },
    0
  );
};

const solidPoints = require("fs")
  .readFileSync("input.txt", "utf-8")
  .split("\n")
  .map((s) => s.split(",").map((s) => parseInt(s)));

const solidPointsHashes = new Set(solidPoints.map((p) => (hash(...p))));
console.log(`Part 1: ${countAllFaces(solidPoints)}`);

const getLimits = (points) => {
  const [minX, minY, minZ] = [0, 1, 2].map((i) => Math.min(...points.map((v) => v[i])) - 1);
  const [maxX, maxY, maxZ] = [0, 1, 2].map((i) => Math.max(...points.map((v) => v[i])) + 1);
  return { minX, minY, minZ, maxX, maxY, maxZ };
};

const countExternalFaces = (point, history, limits, solidPointsHashes) => {
  if (point[0] < limits.minX || point[0] > limits.maxX || point[1] < limits.minY || point[1] > limits.maxY || point[2] < limits.minZ || point[2] > limits.maxZ) { 
    return 0;
  }

  const hashVal = hash(...point);
  if (solidPointsHashes.has(hashVal)) { return 1; }
  if (history.has(hashVal)) { return 0; }
  history.add(hashVal);

  return countExternalFaces([point[0] + 1, point[1], point[2]], history, limits, solidPointsHashes) +
    countExternalFaces([point[0] - 1, point[1], point[2]], history, limits, solidPointsHashes) +
    countExternalFaces([point[0], point[1] + 1, point[2]], history, limits, solidPointsHashes) +
    countExternalFaces([point[0], point[1] - 1, point[2]], history, limits, solidPointsHashes) +
    countExternalFaces([point[0], point[1], point[2] + 1], history, limits, solidPointsHashes) +
    countExternalFaces([point[0], point[1], point[2] - 1], history, limits, solidPointsHashes);
};

const limits = getLimits(solidPoints);
console.log(`Part 2: ${countExternalFaces([limits.minX, limits.minY, limits.minZ], new Set(), limits, solidPointsHashes)}`);
