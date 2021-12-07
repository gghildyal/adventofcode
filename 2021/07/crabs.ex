defmodule AlignCrabs do
  @input [16,1,2,0,4,2,7,1,2,14]
  @filename "./input.txt"

  def align_cost(move_to, positions) do
    positions
      |> Enum.map(fn pos ->
          abs(pos - move_to)
        end)
      |> Enum.sum()
  end

  def read() do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.flat_map(&String.split(&1, ","))
    |> Enum.map(&String.to_integer/1)
  end

  def process do
    inputs = read()
    Enum.to_list(Enum.min(inputs)..Enum.max(inputs))
    |> Enum.map(&(align_cost(&1, inputs)))
    |> Enum.min()
  end

  def align_cost_2(move_to, positions) do
    positions
      |> Enum.map(fn pos ->
          steps = abs(pos - move_to)
          (steps * (steps + 1)) / 2
        end)
      |> Enum.sum()
  end

  def process_2 do
    inputs = read()
    Enum.to_list(Enum.min(inputs)..Enum.max(inputs))
    |> Enum.map(&(align_cost_2(&1, inputs)))
    |> Enum.min()
  end
end
