defmodule DayTwo do
  @year 2023
  @day 2
  @filepath "data.txt"

  def get_bag() do

    %{
      blue: 14, green: 13, red: 12
    }
  end

  def parse_hand(hand) do
    stuff = hand
      |> String.trim()
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.split(&1, " "))

    to_tuple = fn line ->
        f = Enum.at(line,0)
        l = Enum.at(line,1)

        # IO.puts("#{f} #{l}")

        %{"#{Enum.at(line,1)}": Enum.at(line,0) |> String.to_integer()}
    end

    out = stuff
      |> Enum.map(to_tuple)
    # IO.puts("#{out}")
    fin = Enum.reduce(out, %{}, &Map.merge(&1,&2, fn _, v1, v2 -> v1 + v2 end))
    fin
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
    out = game |> Map.get(:runs) |> Enum.reduce(%{}, &Map.merge(&1,&2, fn _, v1, v2 -> Enum.max([v1,v2]) end))
    IO.inspect(out, label: "get_min_bag")
    out
  end

  def is_hand_possible(hand) do
    bag = get_bag()
    IO.inspect(hand)
    IO.inspect(bag)

    out = Map.merge(bag, hand, fn _, v1, v2 -> v1 >= v2 end)
      |> Map.values()
      |> Enum.all?()
    IO.inspect(out)
  end

  def is_game_possible(game) do

    out = game |> Map.get(:runs) |> Enum.map(&DayTwo.is_hand_possible/1) |> Enum.all?()
    IO.inspect(out, label: "isgamepos")
    out
  end

  def solution_one(data) do
    out = data
      |> String.split("\n")
      |> Enum.map(&DayTwo.line_to_map/1)
      |> Enum.filter(&DayTwo.is_game_possible/1)
      |> Enum.map(&Map.get(&1, :game))
      |> Enum.sum()
    IO.inspect(out, label: "solution one")
  end

  def get_set_power(cube_set) do
    Map.get(cube_set, :red) * Map.get(cube_set, :green) * Map.get(cube_set, :blue)
  end

  def solution_two(data) do
    out = data
      |> String.split("\n")
      |> Enum.map(&DayTwo.line_to_map/1)
      |> Enum.map(&DayTwo.get_min_bag/1)
      |> Enum.map(&DayTwo.get_set_power/1)
      |> Enum.sum()
    IO.inspect(out, label: "solution two")
  end

  def run do
    IO.puts("Starting...")
    case System.get_env("ADVENT_HOME") do
      value when is_binary(value) ->
        filepath = "#{value}/#{@year}/data/day#{@day}/#{@filepath}"
        case File.read(filepath) do
          {:ok, content} ->
            IO.puts("Put code here")
            # IO.puts("#{content}")
            solution_one(content)
            solution_two(content)
          {:error, reason} ->
            IO.puts("Could not read file because #{reason}")
        end
      nil ->
        IO.puts("env var not found")
    end
  end
end

DayTwo.run()
