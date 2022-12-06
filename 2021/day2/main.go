package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type Direction struct {
	dir  string
	dist int
}

func main() {
	part1()
	part2()
}

func part1() {
	b, err := ioutil.ReadFile("input")
	if err != nil {
		panic(err)
	}

	strCommands := strings.Split(string(b), "\n")

	dirCommands := []*Direction{}

	for _, direction := range strCommands {
		// ["forward", "9"]
		sp := strings.Split(direction, " ")

		if len(sp) == 2 {
			intDist, _ := strconv.Atoi(sp[1])
			newDir := &Direction{dir: sp[0], dist: intDist}
			dirCommands = append(dirCommands, newDir)
		}
	}

	horizontalDelta := 0
	depthDelta := 0

	for _, command := range dirCommands {
		switch command.dir {
		case "forward":
			horizontalDelta += command.dist
		case "down":
			depthDelta += command.dist
		case "up":
			depthDelta -= command.dist
		default:
			panic("invalid direction")
		}
	}

	fmt.Println("PART 1")
	fmt.Printf("horizontalDelta: %d, depthDelta: %d\n", horizontalDelta, depthDelta)
	fmt.Printf("multiplied: %d\n", horizontalDelta*depthDelta)
}

func part2() {
	b, err := ioutil.ReadFile("input")
	if err != nil {
		panic(err)
	}

	strCommands := strings.Split(string(b), "\n")

	dirCommands := []*Direction{}

	for _, direction := range strCommands {
		// ["forward", "9"]
		sp := strings.Split(direction, " ")

		if len(sp) == 2 {
			intDist, _ := strconv.Atoi(sp[1])
			newDir := &Direction{dir: sp[0], dist: intDist}
			dirCommands = append(dirCommands, newDir)
		}
	}

	horizontalDelta := 0
	depthDelta := 0
	aim := 0

	for _, command := range dirCommands {
		switch command.dir {
		case "forward":
			horizontalDelta += command.dist
			depthDelta += command.dist * aim
		case "down":
			aim += command.dist
		case "up":
			aim -= command.dist
		default:
			panic("invalid direction")
		}
	}

	fmt.Println("PART 2")
	fmt.Printf("horizontalDelta: %d, depthDelta: %d\n", horizontalDelta, depthDelta)
	fmt.Printf("multiplied: %d\n", horizontalDelta*depthDelta)
}
