defmodule DayFour do
  @year 2023
  @day 4
  @filepath "data.txt"

  def parse_line_data(data) do
    tokens = data |> String.split(":")

    card_num =
      tokens |> Enum.at(0) |> String.split(" ", trim: true) |> Enum.at(-1) |> String.to_integer()

    winning_nums =
      tokens
      |> Enum.at(1)
      |> String.split("|", trim: true)
      |> Enum.at(0)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    your_nums =
      tokens
      |> Enum.at(1)
      |> String.split("|", trim: true)
      |> Enum.at(-1)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    matches = DayFour.count_winning({winning_nums, your_nums})
    {card_num, winning_nums, your_nums, matches}
  end

  def count_winning(card) do
    {winning_nums, your_nums} = card

    size =
      MapSet.intersection(
        winning_nums |> Enum.into(MapSet.new()),
        your_nums |> Enum.into(MapSet.new())
      )
      |> MapSet.size()
  end

  def expand_cards(in_hand, card_map) do
    idx = elem(in_hand, 0)
    matches = elem(in_hand, 3)

    case matches do
      0 ->
        [elem(in_hand, 0)]

      matches ->
        [elem(in_hand, 0)] ++
          ((idx+1)..(idx + matches)
           |> Enum.map(&Map.get(card_map, &1))
           |> Enum.flat_map(&DayFour.expand_cards(&1, card_map)))
    end
  end

  def solve_part_one(parsed_data) do
    card_points =
      parsed_data
      |> Enum.map(&elem(&1, 3))
      |> Enum.map(fn size ->
        case size do
          0 -> 0
          size -> :math.pow(2, size - 1)
        end
      end)
      |> Enum.sum()

    IO.inspect(card_points, label: "Solution 1")
  end

  def solve_part_two(parsed_data) do
    map = parsed_data |> Enum.group_by(&elem(&1, 0)) |> Enum.reduce( %{}, fn {key, value}, acc ->
      Map.put(acc, key, Enum.at(value, 0))
    end)

    total_cards = Enum.flat_map(parsed_data, &DayFour.expand_cards(&1, map))
      |> Enum.count()
    IO.inspect(total_cards, label: "solve_part_two")
  end

  def solve(data) do
    parsed_data =
      data
      |> String.split("\n")
      |> Enum.map(&DayFour.parse_line_data/1)

    solve_part_one(parsed_data)
    solve_part_two(parsed_data)

    :exit
  end

  def run do
    IO.puts("Starting...")

    case System.get_env("ADVENT_HOME") do
      value when is_binary(value) ->
        filepath = "#{value}/#{@year}/data/day#{@day}/#{@filepath}"

        case File.read(filepath) do
          {:ok, content} ->
            IO.puts("Put code here\n")
            solve(content)

          {:error, reason} ->
            IO.puts("Could not read file because #{reason}")
        end

      nil ->
        IO.puts("env var not found")
    end
  end
end

DayFour.run()
