use std::fmt::Debug;

#[derive(Debug)]
struct Rucksack<'a> {
    compartment1: &'a str,
    compartment2: &'a str,
}


fn main() {
    let data = include_str!("../test_input").split("\n").collect::<Vec<&str>>();

    for d in &data {
        println!("d: {}", d);
    }

    println!("data: {:?}", data);
}
