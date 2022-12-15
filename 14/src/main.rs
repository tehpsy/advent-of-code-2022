use {
    std::{
        collections::{HashSet, HashMap},
        str::FromStr,
        num::ParseIntError,
        fs::File,
        io::{prelude::*, BufReader},
        path::Path,
    },
};

#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash, Default)]
struct Point {
    x: i32,
    y: i32,
}

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
enum Fill {
    Wall,
    Sand,
    Abyss
}

impl std::fmt::Display for Point {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

fn create_initial_state(filename: impl AsRef<Path>) -> HashMap<Point, Fill> {
    let file = File::open(filename).expect("No such file");
    let mut point_set = HashMap::new();
    let lines = BufReader::new(file).lines().map(|l| l.expect("Could not parse line"));

    let points = lines.map(|string| {
        string.split(" -> ").map(|slice| {
            let coords = slice.split(",").collect::<Vec<&str>>();
            Point {x: coords[0].parse::<i32>().unwrap(), y: coords[1].parse::<i32>().unwrap()} 
        }).collect::<Vec<Point>>()
    }).collect::<Vec<Vec<Point>>>();
    
    for point_arr in points {
        let size = point_arr.len();
        for i in 0..size-1 {
            let point1 = point_arr[i];
            let point2 = point_arr[i+1];
            
            if point1.x == point2.x {
                for y in (std::cmp::min(point1.y, point2.y))..=(std::cmp::max(point1.y, point2.y)) {
                    point_set.insert(Point{x: point1.x, y: y}, Fill::Wall);
                }
            }

            if point1.y == point2.y {
                for x in (std::cmp::min(point1.x, point2.x))..=(std::cmp::max(point1.x, point2.x)) {
                    point_set.insert(Point{x: x, y: point1.y}, Fill::Wall);
                }
            }            
        }
    }

    point_set
}

fn add_floor(state: & mut HashMap<Point, Fill>) {
    let x_values = state.keys().map(|&p| p.x).collect::<Vec<i32>>();
    let y_values = state.keys().map(|&p| p.y).collect::<Vec<i32>>();
    let max_y = y_values.iter().max().unwrap();
    let floor_y = max_y + 2;
    for x in (500-floor_y)..=(500+floor_y) {
        state.insert(Point{x: x, y: floor_y}, Fill::Wall);
    }
}

fn populate_abyss(state: & mut HashMap<Point, Fill>) {
    let mut abyss_points = HashSet::<Point>::new();

    for (point, _) in state.iter() {
        if state.keys().find(|&&p| p.x == point.x - 1 && p.y >= point.y) == None {
            abyss_points.insert(Point{x: point.x - 1, y: point.y});
        }

        if state.keys().find(|&&p| p.x == point.x + 1 && p.y >= point.y) == None {
            abyss_points.insert(Point{x: point.x + 1, y: point.y});
        }
    }

    for point in abyss_points {
        state.insert(point, Fill::Abyss);
    }
}

fn tick(state: & mut HashMap<Point, Fill>, source_point: Point) -> Result<Option<Point>, i8> {
    let next_points = vec![
        Point{x: source_point.x,     y: source_point.y + 1},
        Point{x: source_point.x - 1, y: source_point.y + 1},
        Point{x: source_point.x + 1, y: source_point.y + 1},
    ];

    for point in next_points {
        match state.get(&point) {
            Some(Fill::Wall) => continue,
            Some(Fill::Sand) => continue,
            Some(Fill::Abyss) => return Err(0),
            None => {
                state.remove(&source_point).unwrap();
                state.insert(point, Fill::Sand);
                return Ok(Some(point));
            },
        }
    }

    return Ok(None);
}

fn run(state: & mut HashMap<Point, Fill>) -> usize {
    let start_point = Point{x: 500, y: 0};
    
    let mut point = start_point;
    state.insert(point, Fill::Sand);
    
    let mut sand_count = 0;

    loop {
        match tick(state, point) {
            Ok(Some(new_point)) => point = new_point,
            Ok(None) => {
                if point == start_point {
                    break;
                }

                point = start_point;
                state.insert(start_point, Fill::Sand);
                sand_count += 1;
            },
            Err(e) => break,
        }
    }
    
    state.iter().filter(|(k, v)| **v == Fill::Sand).count()
}

fn main() {
    let state  = create_initial_state("input.txt");
    
    let mut part1 = state.clone();
    populate_abyss(& mut part1);
    println!("Part1: {:?}", run(& mut part1) - 1);

    let mut part2 = state.clone();
    add_floor(& mut part2);
    println!("Part2: {:?}", run(& mut part2));
}
