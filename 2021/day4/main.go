package main

import (
	"bufio"
	"errors"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type Placement struct {
	num    int
	marked bool
}

type BingoGame struct {
	callOrder []int
	boards    [][][]Placement
}

func main() {
	// game := newBingoGame(2, "test_input")
	game := newBingoGame(3, "example_input")
	// game := newBingoGame(100, "input")
	// game.printAllBoards()

	for _, call := range game.callOrder {
		game.markSpaces(call)
		winningBoard, err := game.checkWin()

		if err != nil {
			fmt.Printf("called %2d, %s\n", call, err)
		} else {
			fmt.Printf("WINNING CALL: %d\n", call)
			fmt.Println("WINNING BOARD")
			printBoard(winningBoard)
			calculateScore(winningBoard, call)
			break
		}
	}
}

func (g *BingoGame) printAllBoards() {
	for i := 0; i < len(g.boards); i++ {
		fmt.Printf("BOARD %d\n", i)
		for j := 0; j < len(g.boards[i]); j++ {
			for k := 0; k < len(g.boards[i][j]); k++ {
				fmt.Printf("%2d ", g.boards[i][j][k].num)
			}
			fmt.Printf("\n")
		}
		fmt.Printf("\n")
	}
}

func printBoard(board [][]Placement) {
	for i := 0; i < len(board); i++ {
		for j := 0; j < len(board[i]); j++ {
			var b string
			if board[i][j].marked {
				b = "T"
			} else {
				b = "F"
			}

			fmt.Printf("{%2d %v} ", board[i][j].num, b)
		}
		fmt.Printf("\n")
	}
}

func calculateScore(board [][]Placement, call int) {
	var unmarkedTotal int
	for i := 0; i < len(board[0]); i++ {
		for j := 0; j < len(board[i]); j++ {
			if !board[i][j].marked {
				unmarkedTotal += board[i][j].num
			}
		}
	}

	fmt.Printf("unmarked total: %d, call: %d\n", unmarkedTotal, call)
	fmt.Printf("score (unmarked total * call) = %d\n", unmarkedTotal*call)
}

func (g *BingoGame) markSpaces(call int) {
	for i := 0; i < len(g.boards); i++ {
		for j := 0; j < len(g.boards[i]); j++ {
			for k := 0; k < len(g.boards[i][j]); k++ {
				if g.boards[i][j][k].num == call {
					g.boards[i][j][k].marked = true
				}
			}
		}
	}
}

func (g *BingoGame) checkWin() ([][]Placement, error) {
	for i := 0; i < len(g.boards); i++ {
		// check rows
		for j := 0; j < len(g.boards[i]); j++ {
			row := g.boards[i][j]

			if row[0].marked && row[1].marked && row[2].marked && row[3].marked && row[4].marked {
				return g.boards[i], nil
			}
		}

		// check columns
		for j := 0; j < len(g.boards[i]); j++ {
			colVals := []bool{}
			for k := 0; k < len(g.boards[i][j]); k++ {
				colVals = append(colVals, g.boards[i][j][k].marked)
			}

			if colVals[0] && colVals[1] && colVals[2] && colVals[3] && colVals[4] {
				return g.boards[i], nil
			}
		}
	}

	return nil, errors.New("no winner")
}

func newBingoGame(numBoards int, filePath string) *BingoGame {
	file, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNum, gameBoardNum, boardRow := 0, -1, 0

	game := &BingoGame{}

	boards := make([][][]Placement, numBoards)

	for i := range boards {
		boards[i] = make([][]Placement, 5)
		for j := 0; j < 5; j++ {
			boards[i][j] = make([]Placement, 5)
		}
	}

	game.boards = boards

	for scanner.Scan() {
		rawText := scanner.Text()
		// fmt.Printf("%s\n", rawText)

		if lineNum == 0 {
			callOrderNumStrs := strings.Split(strings.Trim(rawText, "\n"), ",")

			var callOrderNums []int
			for _, callOrderNumStr := range callOrderNumStrs {
				n, _ := strconv.Atoi(callOrderNumStr)
				callOrderNums = append(callOrderNums, n)
			}

			game.callOrder = callOrderNums
		} else if rawText == "" {
			// board separator, advance
			boardRow = 0
			gameBoardNum++
		} else {
			// append board row

			// trim leading spaces and trailing newline
			trimmed := strings.Trim(rawText, "\n ")
			oneSpaced := strings.ReplaceAll(trimmed, "  ", " ")
			lineNumStrs := strings.Split(oneSpaced, " ")
			var placements []Placement
			for _, lineNumStr := range lineNumStrs {
				n, _ := strconv.Atoi(lineNumStr)
				placements = append(placements, Placement{n, false})
			}
			game.boards[gameBoardNum][boardRow] = placements

			boardRow++
		}
		lineNum++
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	return game
}
