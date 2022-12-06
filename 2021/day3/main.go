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
	fmt.Println("PART 1")

	b, err := ioutil.ReadFile("input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.Trim(string(b), "\n"), "\n")

	arr := [][]string{}
	for _, line := range lines {
		split := strings.Split(line, "")
		arr = append(arr, split)
	}

	transposed := transpose(arr)

	gamma := []string{}
	epsilon := []string{}
	for _, line := range transposed {
		ones := 0
		zeros := 0
		for _, bit := range line {
			switch bit {
			case "1":
				ones += 1
			case "0":
				zeros += 1
			}
		}
		if ones > zeros {
			gamma = append(gamma, "1")
			epsilon = append(epsilon, "0")
		} else {
			gamma = append(gamma, "0")
			epsilon = append(epsilon, "1")
		}
	}

	gamma2, _ := strconv.ParseInt(strings.Join(gamma, ""), 2, 64)
	epsilon2, _ := strconv.ParseInt(strings.Join(epsilon, ""), 2, 64)

	fmt.Printf("gamma: %v -> %v\n", gamma, gamma2)
	fmt.Printf("epsilon: %v  -> %v\n", epsilon, epsilon2)

	fmt.Printf("power: gamma * epsilon = %v\n", gamma2*epsilon2)
}

func transpose(slice [][]string) [][]string {
	x1 := len(slice[0])
	y1 := len(slice)

	result := make([][]string, x1)
	for i := range result {
		result[i] = make([]string, y1)
	}

	for i := 0; i < x1; i++ {
		for j := 0; j < y1; j++ {
			result[i][j] = slice[j][i]
		}
	}

	return result
}

func part2() {
	fmt.Println("PART 2")

	b, err := ioutil.ReadFile("input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.Trim(string(b), "\n"), "\n")

	arr := [][]string{}
	for _, line := range lines {
		split := strings.Split(line, "")
		arr = append(arr, split)
	}

	oxyRating := calculateRating(arr, "oxy")
	co2Rating := calculateRating(arr, "co2")

	oxyRatingNum, _ := strconv.ParseInt(strings.Join(oxyRating, ""), 2, 64)
	co2RatingNum, _ := strconv.ParseInt(strings.Join(co2Rating, ""), 2, 64)

	fmt.Printf("oxyRating: %v -> %v\n", oxyRating, oxyRatingNum)
	fmt.Printf("co2Rating: %v -> %v\n", co2Rating, co2RatingNum)
	fmt.Printf("life support rating: %v\n", oxyRatingNum*co2RatingNum)
}
func calculateRating(rows [][]string, ratingType string) []string {
	return makeCalculation(rows, 0, ratingType)
}

func makeCalculation(rows [][]string, pos int, ratingType string) []string {
	newRows := [][]string{}

	if len(rows) == 1 {
		return rows[0]
	}

	onesIdxs, zeroIdxs := []int{}, []int{}
	for idx, row := range rows {
		// fmt.Printf("row = %s\n", row)
		if row[pos] == "1" {
			onesIdxs = append(onesIdxs, idx)
		}
		if row[pos] == "0" {
			zeroIdxs = append(zeroIdxs, idx)
		}
	}

	switch ratingType {
	case "oxy":
		if (len(onesIdxs) > len(zeroIdxs)) || (len(onesIdxs) == len(zeroIdxs)) {
			for _, idx := range onesIdxs {
				newRows = append(newRows, rows[idx])
			}
		} else if len(onesIdxs) < len(zeroIdxs) {
			for _, idx := range zeroIdxs {
				newRows = append(newRows, rows[idx])
			}
		}
	case "co2":
		if (len(onesIdxs) > len(zeroIdxs)) || (len(onesIdxs) == len(zeroIdxs)) {
			for _, idx := range zeroIdxs {
				newRows = append(newRows, rows[idx])
			}
		} else if len(onesIdxs) < len(zeroIdxs) {
			for _, idx := range onesIdxs {
				newRows = append(newRows, rows[idx])
			}
		}
	}

	fmt.Printf("arr size %d -> %d, len(onesIdxs): %d, len(zeroIdxs): %d\n", len(rows), len(newRows), len(onesIdxs), len(zeroIdxs))

	return makeCalculation(newRows, pos+1, ratingType)
}
