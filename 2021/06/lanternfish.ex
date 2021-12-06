defmodule Lanternfish do
  @filename "./input.txt"
  @input [3, 4, 3, 1, 2]
  @num_days 80

  def get_total(fishes, num) when num == 0 do
    fishes
  end

  def get_total(fishes, num) do
    fishes
    |> Enum.reduce([], fn life, acc ->
        cond do
          life == 0 -> [6, 8 | acc]
          true -> [life - 1 | acc]
        end
      end)
    |> get_total(num - 1)
  end

  def read() do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.flat_map(&String.split(&1, ","))
    |> Enum.map(&String.to_integer/1)
  end

  def process() do
    read()
    |> get_total(@num_days)
    |> Enum.count()
  end

end
