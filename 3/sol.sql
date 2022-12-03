CREATE TABLE rucksacks (ID  SERIAL PRIMARY KEY, contents varchar not null);
INSERT INTO rucksacks (contents) VALUES
('your'),
('input'),
('here');

CREATE TABLE letters (ID SERIAL PRIMARY KEY, letter varchar not null);
INSERT INTO letters (letter) VALUES
('a'), ('b'), ('c'), ('d'), ('e'), ('f'), ('g'), ('h'), ('i'), ('j'), ('k'), ('l'), ('m'), ('n'), ('o'), ('p'), ('q'), ('r'), ('s'), ('t'), ('u'), ('v'), ('w'), ('x'), ('y'), ('z'), 
('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J'), ('K'), ('L'), ('M'), ('N'), ('O'), ('P'), ('Q'), ('R'), ('S'), ('T'), ('U'), ('V'), ('W'), ('X'), ('Y'), ('Z');

-- Part 1

WITH products AS (
WITH split_strings AS (
	SELECT 
		contents,
		(SUBSTRING (contents, 0, 1 + length(contents) / 2)) as FirstHalf,
		(SUBSTRING (contents, 1 + length(contents) / 2, length(contents))) as SecondHalf
	FROM rucksacks
)
SELECT DISTINCT * FROM split_strings
CROSS JOIN letters
WHERE FirstHalf ~ letter
AND SecondHalf ~ letter
)
SELECT SUM(id) from products;

-- Part 2

ALTER TABLE rucksacks ADD group_id int;

UPDATE rucksacks SET group_id = (id - 1) / 3;

WITH products AS (
  WITH combined_strings AS (
    SELECT
      MAX(r.contents) FILTER (WHERE r.row_number = 1) AS string1,
      MAX(r.contents) FILTER (WHERE r.row_number = 2) AS string2,
      MAX(r.contents) FILTER (WHERE r.row_number = 3) AS string3
    FROM (
      SELECT *,
        ROW_NUMBER() OVER (PARTITION BY r.group_id ORDER BY r.contents) AS row_number
      FROM rucksacks r
    ) r
    GROUP BY r.group_id
  )
  SELECT DISTINCT * FROM combined_strings
  CROSS JOIN letters
  WHERE string1 ~ letter AND string2 ~ letter AND string3 ~ letter
)
SELECT SUM(id) from products;