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

defmodule LanternfishOptimized do
  @filename "./input.txt"
  @input [3, 4, 3, 1, 2]
  @num_days 256

  def get_total(fishes, num) when num == @num_days do
    fishes
  end

  def get_total(fishes, num) do
    fishes
    |> Enum.reduce(fishes, fn {life, freq}, acc ->#
        cond do
          life == 0 ->
            acc = Map.put(acc, 6, freq)
            Map.put(acc, 8, freq)
          life == 7 ->
            Map.update(acc, life - 1, freq, &(&1 + freq))
          true ->
            Map.put(acc, life - 1, freq)
        end
      end)
    |> get_total(num + 1)
  end

  def read() do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.flat_map(&String.split(&1, ","))
    |> Enum.map(&String.to_integer/1)
  end

  def get_map(fishes) do
    Map.new(Enum.zip(Enum.to_list(0..9), List.duplicate(0, 9)))
    |> Map.merge(Enum.frequencies(fishes))
  end

  def process() do
    read()
    |> get_map()
    |> get_total(0)
    |> Map.values
    |> Enum.sum
  end

end
