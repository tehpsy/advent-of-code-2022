use {
    std::{
        collections::{HashSet},
        str::FromStr,
        num::ParseIntError,
        fs::File,
        io::{prelude::*, BufReader},
        path::Path,
    },
};

#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash, Default)]
struct Knot {
    x: i32,
    y: i32,
}

impl std::fmt::Display for Knot {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

impl std::fmt::Display for State {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self.knots)
    }
}

#[derive(Debug, Clone, Eq, PartialEq, Hash)]
struct State {
    knots: Vec<Knot>
}

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right
}

impl FromStr for Direction {
    type Err = ParseIntError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "U" => return Ok(Direction::Up),
            "D" => return Ok(Direction::Down),
            "L" => return Ok(Direction::Left),
            "R" => return Ok(Direction::Right),
            _ => panic!("Unknown direction")
        }
    }
}

impl Knot {
    fn moving(&self, directions: &Vec<Direction>) -> Knot {
        directions.iter().fold(
            self.clone(),
            |mut knot, direction| {
                match direction {
                    Direction::Up => knot = Knot { x: knot.x, y: knot.y + 1 },
                    Direction::Down => knot = Knot { x: knot.x, y: knot.y - 1 },
                    Direction::Left => knot = Knot { x: knot.x - 1, y: knot.y },
                    Direction::Right => knot = Knot { x: knot.x + 1, y: knot.y },
                }
                knot
            })
    }

    fn adjacent_to(&self, knot: &Knot) -> bool {
        (self.x - &knot.x).abs() <= 1 &&
        (self.y - &knot.y).abs() <= 1
    }

    fn directions_towards(&self, knot: &Knot) -> Vec<Direction> {
        let mut vec: Vec<Direction> = vec![];
        if knot.x > self.x { vec.push(Direction::Right); }
        else if knot.x < self.x { vec.push(Direction::Left); };

        if knot.y > self.y { vec.push(Direction::Up); }
        else if knot.y < self.y { vec.push(Direction::Down); };
        vec
    }
}

impl State {
    fn moving(&self, direction: &Direction) -> State {
        let mut new_knots = vec![self.knots[0].moving(&vec![*direction])];
        for (_, knot) in self.knots[1..].iter().enumerate() {
            let forward_knot = new_knots.last().unwrap();
            if forward_knot.adjacent_to(&knot) {
                new_knots.push(*knot);
                continue;
            } 

            let directions = knot.directions_towards(forward_knot);
            let new_knot = knot.moving(&directions);
            new_knots.push(new_knot);
        }

        State {knots: new_knots}
    }
}

impl State {
    fn create(knot_count: usize) -> State {
        State { knots: vec![Knot::default(); knot_count] }
    }
}

fn run(instructions: &Vec<(Direction, i32)>, knot_count: usize) {
    let mut state = State::create(knot_count);

    let tail_positions: HashSet::<Knot> = instructions.iter().fold(
        HashSet::<Knot>::default(),
        |mut hashset, instruction| {
            for _ in 0..instruction.1 {
                state = state.moving(&instruction.0);
                hashset.insert(*state.knots.last().unwrap());
            }
            hashset
    });
    
    println!("Knot count {}, tail covers: {}", knot_count, tail_positions.len());
}

fn split_strings_from_file(filename: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(filename).expect("No such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line"))
        .collect()
}

fn parse_instructions(instructions: &Vec<String>) -> Vec<(Direction, i32)> {
    instructions.iter().map(|line| {
        let args = line.split_whitespace().collect::<Vec<&str>>();
        let direction = Direction::from_str(&args[0]).unwrap();
        let steps = args[1].parse::<i32>().unwrap();
        (direction, steps)
    }).collect()
}

fn main() {
    let lines: Vec<String>  = split_strings_from_file("input.txt");
    let instructions = parse_instructions(&lines);
    run(&instructions, 2);
    run(&instructions, 10);
}
