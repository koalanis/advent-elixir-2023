defmodule DayTwo do
  @year 2023
  @day 2
  @filepath "data.txt"

  def get_bag() do
    %{
      blue: 14,
      green: 13,
      red: 12
    }
  end

  def parse_hand(hand) do
    to_tuple = fn line ->
      f = Enum.at(line, 0)
      l = Enum.at(line, 1)
      %{"#{Enum.at(line, 1)}": Enum.at(line, 0) |> String.to_integer()}
    end

    hand
      |> String.trim() # trim string
      |> String.split(",", trim: true) # then split on space to list
      |> Enum.map(&String.trim/1) # then map-apply  trim on each list element
      |> Enum.map(&String.split(&1, " ")) # then map-apply split on space on each list element
      |> Enum.map(to_tuple) # transform array into dictionary
      |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _, v1, v2 -> v1 + v2 end)) # reduce all dictionaries, handle dups with addition accumulator
  end

  def line_to_map(line) do
    tokens = line |> String.split(":")

    game_num = tokens |> Enum.at(0) |> String.split(" ") |> Enum.at(-1) |> String.to_integer()
    game_runs = tokens |> Enum.at(1) |> String.split(";") |> Enum.map(&DayTwo.parse_hand/1)

    %{
      game: game_num,
      runs: game_runs
    }
  end

  def get_min_bag(game) do
    out =
      game
      |> Map.get(:runs)
      |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _, v1, v2 -> Enum.max([v1, v2]) end))
    out
  end

  def is_hand_possible(hand) do
    Map.merge(get_bag(), hand, fn _, v1, v2 -> v1 >= v2 end)
      |> Map.values()
      |> Enum.all?()
  end

  def is_game_possible(game) do
    game |> Map.get(:runs) |> Enum.map(&DayTwo.is_hand_possible/1) |> Enum.all?()
  end

  def get_set_power(cube_set) do
    Map.get(cube_set, :red) * Map.get(cube_set, :green) * Map.get(cube_set, :blue)
  end

  def solution_one(data) do
    out =
      data
      |> Enum.filter(&DayTwo.is_game_possible/1)
      |> Enum.map(&Map.get(&1, :game))
      |> Enum.sum()

    IO.inspect(out, label: "solution one")
  end

  def solution_two(data) do
    out =
      data
      |> Enum.map(&DayTwo.get_min_bag/1)
      |> Enum.map(&DayTwo.get_set_power/1)
      |> Enum.sum()

    IO.inspect(out, label: "solution two")
  end


  def parse_data(data) do
    data
      |> String.split("\n")
      |> Enum.map(&DayTwo.line_to_map/1)
  end

  def run do
    case System.get_env("ADVENT_HOME") do
      value when is_binary(value) ->
        filepath = "#{value}/#{@year}/data/day#{@day}/#{@filepath}"

        case File.read(filepath) do
          {:ok, content} ->
            parsed = parse_data(content)
            solution_one(parsed)
            solution_two(parsed)

          {:error, reason} ->
            IO.puts("Could not read file because #{reason}")
        end

      nil ->
        IO.puts("env var not found")
    end
  end
end

DayTwo.run()
