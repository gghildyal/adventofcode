defmodule HypothermalVenture do
  @filename "./input.txt"

  def read_segments do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.map(
      fn line -> String.split(line, " -> ")
        |> Enum.map(fn entry -> String.split(entry, ",")
          |> Enum.map(fn token -> String.to_integer(token) end) end)
        |> Enum.map(fn entry -> List.to_tuple(entry) end)
      end)
  end

  def expand([{x1, y1}, {x2, y2}]) do
    cond do
      x1 == x2 -> Enum.zip(List.duplicate(x1, Enum.count(y1..y2)), Enum.to_list(y1..y2))
      y1 == y2 -> Enum.zip(Enum.to_list(x1..x2), List.duplicate(y1, Enum.count(x1..x2)))
      true -> []
    end
  end

  def process do
    read_segments()
    |> Enum.flat_map(&expand/1)
    |> Enum.frequencies()
    |> Enum.reject(fn {_, v} -> v < 2 end)
    |> length()
  end
end
