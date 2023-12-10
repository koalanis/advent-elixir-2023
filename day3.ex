defmodule DayThree do
  @year 2023
  @day 3
  @filepath "data.txt"

  def line_to_tokens({line, idx}) do
    pattern = ~r/\d+/
    sym_pattern = ~r/[^a-zA-Z0-9.]/

    tuple_to_struct = fn {f, l} ->
      %{index: f, binary: binary_part(line, f, l), size: l, row: idx}
    end

    part_numbers =
      Regex.scan(pattern, line, return: :index)
      |> Enum.flat_map(& &1)
      |> Enum.map(tuple_to_struct)

    specials =
      Regex.scan(sym_pattern, line, return: :index)
      |> Enum.flat_map(& &1)
      |> Enum.map(tuple_to_struct)

    %{
      nums: part_numbers,
      specials: specials
    }
  end

  def tokens_to_coors(data) do
    index = Map.get(data, :index)
    row = Map.get(data, :row)

    {
      {row, index},
      data
    }
  end

  def get_neighborhood(num, row_bounds, col_bounds) do
    {row, index, size} = {Map.get(num, :row), Map.get(num, :index), Map.get(num, :size)}

    top = for i <- (index - 1)..(index + size), do: {row - 1, i}
    bottom = for i <- (index - 1)..(index + size), do: {row + 1, i}
    sides = [{row, index - 1}, {row, index + size}]
    all = top ++ bottom ++ sides

    all |> Enum.filter(fn {r, c} -> 0 <= r && r < row_bounds && 0 <= c && c < col_bounds end)
  end

  def check_if_near_symbol(num, symbol_map, row_bounds, col_bounds) do
    get_neighborhood(num, row_bounds, col_bounds)
    |> Enum.map(&Map.has_key?(symbol_map, &1))
    |> Enum.any?(&(&1 == true))
  end

  def get_gear_power(rc, list, row_bounds, col_bounds) do
    row = rc.row

    compute = fn gear, num ->
      s_r = gear.row
      s_c = gear.index

      nei =
        [
          {s_r - 1, s_c - 1},
          {s_r - 1, s_c},
          {s_r - 1, s_c + 1},
          {s_r, s_c - 1},
          {s_r, s_c + 1},
          {s_r + 1, s_c - 1},
          {s_r + 1, s_c},
          {s_r + 1, s_c + 1}
        ]
        |> Enum.filter(fn {r, c} -> 0 <= r && r < row_bounds && 0 <= c && c < col_bounds end)
        |> Enum.into(MapSet.new())

      n_r = num.row
      n_c = num.index
      num_span = for n <- n_c..(n_c + num.size - 1), do: {n_r, n}
      num_span = num_span |> Enum.into(MapSet.new())

      MapSet.intersection(nei, num_span)
      |> MapSet.size() > 0
    end

    out =
      [Enum.at(list, row - 1), Enum.at(list, row), Enum.at(list, row + 1)]
      |> Enum.filter(&(&1 != nil))
      |> Enum.flat_map(&Map.get(&1, :nums))
      |> Enum.filter(&compute.(rc, &1))

    case out |> length() do
      2 ->
        out
        |> Enum.map(&Map.get(&1, :binary))
        |> Enum.map(&String.to_integer/1)
        |> Enum.reduce(1, fn a, b -> a * b end)

      _ ->
        0
    end
  end

  def row_to_gear_power(row, list, row_bounds, col_bounds) do
    filter_fn = fn m ->
      case m.binary do
        "*" -> DayThree.get_gear_power(m, list, row_bounds, col_bounds)
        _ -> 0
      end
    end

    row
    |> Map.get(:specials)
    |> Enum.map(filter_fn)
    |> Enum.sum()
  end

  def solve_part_1(matrix, row_bounds, col_bounds) do
    all_elements = matrix |> Enum.reduce(%{}, &Map.merge(&1, &2, fn _, v1, v2 -> v1 ++ v2 end))

    symbol_map =
      all_elements
      |> Map.get(:specials)
      |> Enum.map(&DayThree.tokens_to_coors/1)
      |> Enum.into(%{})

    part_numbers_adjacent_to_symbols =
      all_elements
      |> Map.get(:nums)
      |> Enum.filter(&DayThree.check_if_near_symbol(&1, symbol_map, row_bounds, col_bounds))

    sum_of_part_nums =
      part_numbers_adjacent_to_symbols
      |> Enum.map(&Map.get(&1, :binary))
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()

    IO.inspect(sum_of_part_nums, label: "Solution 1")
    :exit
  end

  def solve_part_2(matrix, row_bounds, col_bounds) do
    sum_of_gear_power =
      matrix
      |> Enum.with_index(0)
      |> Enum.map(&DayThree.row_to_gear_power(elem(&1, 0), matrix, row_bounds, col_bounds))
      |> Enum.sum()

    IO.inspect(sum_of_gear_power, label: "Solution 2")
    :exit
  end

  def solve(data) do
    out =
      data
      |> String.split("\n", trim: true)

    col_bounds = Enum.at(out, 0) |> String.length()
    row_bounds = out |> length()

    matrix =
      out
      |> Enum.with_index(0)
      |> Enum.map(&DayThree.line_to_tokens/1)

    solve_part_1(matrix, row_bounds, col_bounds)
    solve_part_2(matrix, row_bounds, col_bounds)

    :exit
  end

  def run do
    IO.puts("Starting...")

    case System.get_env("ADVENT_HOME") do
      value when is_binary(value) ->
        filepath = "#{value}/#{@year}/data/day#{@day}/#{@filepath}"

        case File.read(filepath) do
          {:ok, content} ->
            IO.puts("Put code here")
            solve(content)

          {:error, reason} ->
            IO.puts("Could not read file because #{reason}")
        end

      nil ->
        IO.puts("env var not found")
    end
  end
end

DayThree.run()
