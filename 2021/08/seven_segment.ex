defmodule SevenSegment do
  @filename "./input.txt"
  @segments MapSet.new(["a", "b", "c", "d", "e", "f", "g"])
  @display_map Map.new(%{
    0 => MapSet.new(["a", "b", "c", "e", "f", "g"]),
    1 => MapSet.new(["c", "f"]),
    2 => MapSet.new(["a", "c", "d", "e", "g"]),
    3 => MapSet.new(["a", "c", "d", "f", "g"]),
    4 => MapSet.new(["b", "d", "c", "f"]),
    5 => MapSet.new(["a", "b", "d", "f", "g"]),
    6 => MapSet.new(["a", "b", "e", "g", "f", "d"]),
    7 => MapSet.new(["a", "c", "f"]),
    8 => MapSet.new(@segments),
    9 => MapSet.new(["a", "c", "d", "f", "g"]),
  })

  def read() do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.map(&String.split(&1, " | "))
  end

  def process_1() do
    to_match = Enum.filter(@display_map, fn {key, _} -> key in [1, 4, 7, 8] end)
    counts = Enum.map(to_match, fn x -> MapSet.size(elem(x, 1)) end)

    read()
    |> Enum.flat_map(fn line -> tl(line) end)
    |> Enum.flat_map(&String.split(&1, " "))
    |> Enum.filter(fn pattern -> String.length(pattern) in counts end)
    |> length()
  end

  def sort_letters(str) do
    str
    |> String.to_charlist()
    |> Enum.sort()
    |> List.to_string()
  end

  def subset?(str_1, str_2) do
    set_1 = MapSet.new(String.to_charlist(str_1))
    set_2 = MapSet.new(String.to_charlist(str_2))
    MapSet.subset?(set_1, set_2)
  end

  def decode_codes_with_len_5(decoded, patterns) do
    patterns |> Enum.reduce(decoded, fn pattern, acc ->
      cond do
        subset?(Map.get(decoded, 7), pattern) ->
          Map.put(acc, 3, pattern)
          subset?(pattern, Map.get(decoded, 6)) ->
            Map.put(acc, 5, pattern)
          true ->
            Map.put(acc, 2, pattern)
      end
    end)
  end

  def decode_codes_with_len_6(decoded, patterns) do
    patterns |> Enum.reduce(decoded, fn pattern, acc ->
        cond do
          subset?(Map.get(decoded, 7), pattern) == false ->
            Map.put(acc, 6, pattern)
          subset?(Map.get(decoded, 7), pattern) and
            subset?(Map.get(decoded, 4), pattern) ->
              Map.put(acc, 9, pattern)
          true ->
            Map.put(acc, 0, pattern)
        end
    end)
  end

  def decode(pattern, decoded) do
    length_map = Enum.group_by(pattern, &String.length/1)
    for fixed <- [{1, 2}, {7, 3}, {4, 4}, {8, 7}], into: decoded do
      {elem(fixed, 0), hd(Map.get(length_map, elem(fixed, 1)))}
    end
    |> decode_codes_with_len_6(Map.get(length_map, 6))
    |> decode_codes_with_len_5(Map.get(length_map, 5))

  end

  def decode_line(line) do
    [patterns, codes] = line
    decoded = patterns
    |> String.split
    |> Enum.sort_by(&String.length/1)
    |> decode(Map.new)
    |> Map.new(fn {key, val} -> {MapSet.new(String.to_charlist(val)), key} end)

    codes
    |> String.split
    |> Enum.map(fn code ->
        code_set = MapSet.new(String.to_charlist(code))
        Map.get(decoded, code_set)
      end)
    |> Enum.join("")
    |> String.to_integer()
  end

  def process_2() do
    read()
    |> Enum.map(&decode_line/1)
    |> Enum.sum()
  end
end
