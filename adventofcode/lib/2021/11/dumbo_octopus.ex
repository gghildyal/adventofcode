defmodule Flashes do
  @filename Path.join([Path.dirname(__ENV__.file), "test_input.txt"])

  def read() do
    File.stream!(@filename)
    |> Enum.map(&String.trim/1)
  end

  def generate_adjacency_map(rows \\ 10, columns \\ 10) do
    for x <- 0..rows-1, y <- 0..columns-1, into: %{} do
      adjacency_list = for subx <- max(0, x-1)..min(x+1, rows-1), suby <- max(0, y-1)..min(y+1, columns-1), into: [], do: {subx, suby}
      adjacency_list = adjacency_list |> Enum.filter(fn entry -> entry != {x, y} end)
      {{x, y}, adjacency_list}
    end
  end

  def generate_matrix(entries) do
    entries
    |> Enum.with_index()
    |> Enum.map(fn {str, row_num} ->
      String.codepoints(str)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {entry, col_num}, acc -> Map.put(acc, {row_num, col_num}, String.to_integer(entry)) end)
    end)
    |> Enum.flat_map(&(&1))
    |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, key, val) end)
  end

  def highlighted?(key, highlighted) do
    Map.has_key?(highlighted, key)
  end

  def flash(matrix, key, adjacency_map, highlighted) do
    case highlighted?(key, highlighted) do
      true -> {matrix, highlighted}
      false ->
        highlighted = Map.put(highlighted, key, true)
        Map.get(adjacency_map, key)
          |> Enum.reduce({matrix, highlighted}, fn {x, y}, {acc, h} ->
            case highlighted?({x, y}, h) do
              true -> {acc, h}
              false ->
                val = Map.get(acc, {x, y})
                case val + 1 > 9 do
                  true ->
                    acc
                    |> Map.put({x, y}, 0)
                    |> flash({x, y}, adjacency_map, h)
                  false -> {Map.put(acc, {x, y}, val + 1), h}
                end
            end
          end)
    end
  end

  def increase_energy(matrix, _, count, flashes) when count == 0 do
    {matrix, flashes}
  end

  def increase_energy(matrix, adjacency_map, count, flashes) do
    highlighted = %{}
    matrix = matrix |> Enum.map(fn {key, val} -> {key, val + 1} end) |> Map.new
    {matrix, highlighted} = matrix |> Enum.reduce({matrix, highlighted}, fn {key, val}, {acc, h} ->
      case val > 9 do
        true ->
          acc
          |> Map.put(key, 0)
          |> flash(key, adjacency_map, h)
        false -> {acc, h}
      end
    end)
    increase_energy(matrix, adjacency_map, count - 1, flashes + map_size(highlighted))
  end

  def until_all_flash(matrix, adjacency_map, iteration_count) do
    highlighted = %{}
    matrix = matrix |> Enum.map(fn {key, val} -> {key, val + 1} end) |> Map.new
    {matrix, highlighted} = matrix |> Enum.reduce({matrix, highlighted}, fn {key, val}, {acc, h} ->
      case val > 9 do
        true ->
          acc
          |> Map.put(key, 0)
          |> flash(key, adjacency_map, h)
        false -> {acc, h}
      end
    end)
    case map_size(highlighted) == map_size(matrix) do
      true -> iteration_count + 1
      false -> until_all_flash(matrix, adjacency_map, iteration_count + 1)
    end
  end

  def process() do
    adjacency_map = generate_adjacency_map(10, 10)
    read()
    |> generate_matrix()
    |> increase_energy(adjacency_map, 100, 0)
    |> elem(1)
  end

  def process_2() do
    adjacency_map = generate_adjacency_map(10, 10)
    read()
    |> generate_matrix()
    |> until_all_flash(adjacency_map, 0)
  end
end
