defmodule RockPaperScissors do
  @moduledoc """
  """

  def part1(file) do
    File.read!(file)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&translate_games/1)
    |> Enum.reduce(0, &calculate_score/2)
  end

  def part2(file) do
    File.read!(file)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&translate_strategy/1)
    |> Enum.reduce(0, &calculate_score2/2)
  end

  defp translate_games("A X"), do: {:rock, :rock}
  defp translate_games("A Y"), do: {:rock, :paper}
  defp translate_games("A Z"), do: {:rock, :scissors}
  defp translate_games("B X"), do: {:paper, :rock}
  defp translate_games("B Y"), do: {:paper, :paper}
  defp translate_games("B Z"), do: {:paper, :scissors}
  defp translate_games("C X"), do: {:scissors, :rock}
  defp translate_games("C Y"), do: {:scissors, :paper}
  defp translate_games("C Z"), do: {:scissors, :scissors}

  defp translate_strategy("A X"), do: {:rock, :lose}
  defp translate_strategy("A Y"), do: {:rock, :tie}
  defp translate_strategy("A Z"), do: {:rock, :win}
  defp translate_strategy("B X"), do: {:paper, :lose}
  defp translate_strategy("B Y"), do: {:paper, :tie}
  defp translate_strategy("B Z"), do: {:paper, :win}
  defp translate_strategy("C X"), do: {:scissors, :lose}
  defp translate_strategy("C Y"), do: {:scissors, :tie}
  defp translate_strategy("C Z"), do: {:scissors, :win}

  defp calculate_score({_opponent, your_play} = play, acc) do
    case outcome(play) do
      :win ->
        6 + points(your_play) + acc

      :tie ->
        3 + points(your_play) + acc

      :lose ->
        0 + points(your_play) + acc
    end
  end

  defp calculate_score2({opponent, desired_outcome} = play, acc) do
    your_play = determine_your_play(opponent, desired_outcome)

    case desired_outcome do
      :win ->
        6 + points(your_play) + acc

      :tie ->
        3 + points(your_play) + acc

      :lose ->
        0 + points(your_play) + acc
    end
  end
  defp outcome({:rock, :paper}), do: :win
  defp outcome({:rock, :scissors}), do: :lose
  defp outcome({:paper, :rock}), do: :lose
  defp outcome({:paper, :scissors}), do: :win
  defp outcome({:scissors, :rock}), do: :win
  defp outcome({:scissors, :paper}), do: :lose
  defp outcome({same, same}), do: :tie

  defp determine_your_play(:rock, :win), do: :paper
  defp determine_your_play(:rock, :tie), do: :rock
  defp determine_your_play(:rock, :lose), do: :scissors

  defp determine_your_play(:paper, :win), do: :scissors
  defp determine_your_play(:paper, :tie), do: :paper
  defp determine_your_play(:paper, :lose), do: :rock

  defp determine_your_play(:scissors, :win), do: :rock
  defp determine_your_play(:scissors, :tie), do: :scissors
  defp determine_your_play(:scissors, :lose), do: :paper

  defp points(:rock), do: 1
  defp points(:paper), do: 2
  defp points(:scissors), do: 3
end

RockPaperScissors.part1("input")
|> IO.inspect(label: "part1 score")

RockPaperScissors.part2("input")
|> IO.inspect(label: "part2 score")
