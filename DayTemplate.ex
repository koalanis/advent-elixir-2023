defmodule DayTemplate do
  @year 2023
  @day 1
  @filepath "data.txt"

  def run do
    IO.puts("Starting...")

    case System.get_env("ADVENT_HOME") do
      value when is_binary(value) ->
        filepath = "#{value}/#{@year}/data/day#{@day}/#{@filepath}"

        case File.read(filepath) do
          {:ok, content} ->
            IO.puts("Put code here")

          {:error, reason} ->
            IO.puts("Could not read file because #{reason}")
        end

      nil ->
        IO.puts("env var not found")
    end
  end
end

DayTemplate.run()
