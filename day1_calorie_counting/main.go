
package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {
	part1()
	part2()
}

func part1() {
	b, err := ioutil.ReadFile("input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(b), "\n")

	elfIndex, biggestElfIndex, curElfCalories, biggestElfCalories := 1, 1, 0, 0

	for _, str := range lines {
		if str != "" {
			i, err := strconv.Atoi(str)
			if err != nil {
				// newline at end of file, could probably guard better against that
				fmt.Println(err)
				continue
			}
			curElfCalories += i
			fmt.Printf("elf %d cal cumulative... %d\n", elfIndex, curElfCalories)
		} else {
			fmt.Printf("elf %d total: %d, current max: {%d, elf%d}\n", elfIndex, curElfCalories, biggestElfCalories, biggestElfIndex)
			if curElfCalories > biggestElfCalories {
				fmt.Printf("NEW MAX! Elf %d overtook Elf %d increasing from %d -> %d\n", elfIndex, biggestElfIndex, biggestElfCalories, curElfCalories)
				biggestElfCalories = curElfCalories
				biggestElfIndex = elfIndex
			}
			curElfCalories = 0
			elfIndex++
		}
	}

	fmt.Printf("elf %d is carrying the most calories: %d\n", biggestElfIndex, biggestElfCalories)
}

func part2() {

}
