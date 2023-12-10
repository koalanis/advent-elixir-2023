defmodule DayOne do
  @year 2023
  @day 1
  @filepath "data.txt"

  def get_num_value_map() do
    num_value_map = %{
      one: "1",
      two: "2",
      three: "3",
      four: "4",
      five: "5",
      six: "6",
      seven: "7",
      eight: "8",
      nine: "9"
    }

    num_value_map
  end

  def find_indices_of_substring(str, target) do
    t =
      case target do
        n when is_atom(n) -> Atom.to_string(target)
        _ -> target
      end

    case :binary.matches(str, t) do
      :nomatch -> [-1]
      index -> Enum.map(index, &elem(&1, 0))
    end
  end

  def turn_str_into_num_seq(str) do
    num_value_map = get_num_value_map()
    numbers = Map.keys(num_value_map)

    spread = fn {num, l} ->
      l |> Enum.map(&{num, &1})
    end

    word_indices =
      Enum.map(numbers, &{&1, find_indices_of_substring(str, &1)})
      |> Enum.flat_map(&spread.(&1))
      |> Enum.map(&{num_value_map[elem(&1, 0)], elem(&1, 1)})

    select = fn a -> elem(a, 1) end
    filter_condition = fn {_num, idx} -> idx >= 0 end

    is_an_int = fn {v, _idx} ->
      case Integer.parse(v) do
        {_, ""} -> true
        _ -> false
      end
    end

    digit_indices =
      str
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.filter(is_an_int)

    number_indices = word_indices ++ digit_indices

    sorted =
      Enum.sort(number_indices, &(select.(&1) < select.(&2))) |> Enum.filter(filter_condition)

    final =
      sorted
      |> Enum.map(&elem(&1, 0))
      |> Enum.join()

    final
  end

  def str_to_first_last_tuple(str) do
    combined = Enum.at(str, 0) <> Enum.at(str, -1)

    case Integer.parse(combined) do
      {first, ""} -> first
      _ -> -1
    end
  end

  def first_last_num(str) do
    str
    |> Enum.filter(&(String.trim(&1) != ""))
    |> Enum.map(&String.graphemes(&1))
    |> Enum.map(&str_to_first_last_tuple(&1))
  end

  def solve_part_one(data) do
    IO.puts("part 1 starting...")

    list =
      data
      |> String.split("\n")
      |> Enum.map(&String.replace(&1, ~r/[a-zA-Z]/, "", global: true))
      |> first_last_num()

    sum = Enum.reduce(list, 0, fn acc, v -> acc + v end)
    IO.puts("Part 1: #{sum}")
  end

  def solve_part_two(data) do
    IO.puts("part 2 starting...")

    list =
      data
      |> String.split("\n")
      |> Enum.map(&turn_str_into_num_seq(&1))
      |> first_last_num()

    sum = Enum.reduce(list, 0, fn acc, v -> acc + v end)
    IO.puts("Part 2: #{sum}")
  end

  def run do
    IO.puts("Starting...")

    case System.get_env("ADVENT_HOME") do
      value when is_binary(value) ->
        filepath = "#{value}/#{@year}/data/day#{@day}/#{@filepath}"

        case File.read(filepath) do
          {:ok, content} ->
            solve_part_one(content)
            solve_part_two(content)

          {:error, reason} ->
            IO.puts("Could not read file because #{reason}")
        end

      nil ->
        IO.puts("env var not found")
    end
  end
end

DayOne.run()
