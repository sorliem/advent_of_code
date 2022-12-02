fn main() {
    let split = include_str!("../input").split("\n");
    let lines = split.collect::<Vec<&str>>();
    let (mut cur_elf_calories, mut biggest_elf_calories) = (0, 0);

    for s in lines {
        if s == "" {
            if cur_elf_calories > biggest_elf_calories {
                println!("NEW MAX!: {} -> {}", biggest_elf_calories, cur_elf_calories);
                biggest_elf_calories = cur_elf_calories;
            }
            cur_elf_calories = 0;
        } else {
            let calories = s.parse::<usize>().unwrap();
            cur_elf_calories += calories;
        }
    }

    println!("biggest calorie amount from single elf: {}", biggest_elf_calories);
}
