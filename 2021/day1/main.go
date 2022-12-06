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

	strs := strings.Split(string(b), "\n")

	numIncreases := 0
	last := 0

	for idx, str := range strs {
		if str != "" {
			i, err := strconv.Atoi(str)
			if err != nil {
				// newline at end of file, could probably guard better against that
				fmt.Println(err)
				continue
			}

			if i > last && idx != 0 {
				numIncreases += 1
			}
			last = i
		}
	}

	fmt.Printf("num_increases = %d\n", numIncreases)
}

func part2() {
	b, err := ioutil.ReadFile("input")
	if err != nil {
		panic(err)
	}

	strs := strings.Split(string(b), "\n")

	rawReadings := []int{}
	for _, str := range strs {
		if str != "" {
			i, _ := strconv.Atoi(str)
			rawReadings = append(rawReadings, i)
		}
	}

	computedReadings := []int{}
	lenReadings := len(rawReadings)

	for idx, reading := range rawReadings {
		if idx+3 <= lenReadings {
			computedReading := reading + rawReadings[idx+1] + rawReadings[idx+2]
			computedReadings = append(computedReadings, computedReading)
		}
	}

	numIncreases := 0
	lastReading := 0

	for idx, cr := range computedReadings {
		if cr > lastReading && idx != 0 {
			numIncreases += 1
		}
		lastReading = cr
	}

	fmt.Printf("sliding window num_increases = %d\n", numIncreases)
}
