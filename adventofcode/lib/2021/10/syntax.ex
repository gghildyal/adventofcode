defmodule SyntaxChecker do
  alias Statistics
  alias Path
  @filename Path.join([Path.dirname(__ENV__.file), "input.txt"])
  @open_to_close_map %{
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
  }
  @points %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
  }

  @completion_scores %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4,
  }

  def read() do
    File.stream!(@filename)
    |> Enum.map(&String.trim/1)
  end

  def pair?(open, close) do
    close == Map.get(@open_to_close_map, open)
  end

  def open?(symbol) do
    Map.has_key?(@open_to_close_map, symbol)
  end

  def close?(symbol) do
    Enum.member?(Map.values(@open_to_close_map), symbol)
  end

  def check_syntax(line, unmatched) when length(line) == 0 do
    {:ok, nil , [], unmatched}
  end

  def check_syntax(line, unmatched) do
    [first | rest] = line
    cond do
      open?(first) ->
        case check_syntax(rest, [Map.get(@open_to_close_map, first) | unmatched]) do
          {:ok, nil, rem, unmatched} -> {:ok, nil, rem, unmatched}
          {:ok, closing, rem, unmatched} ->
            case pair?(first, closing) do
              true -> check_syntax(rem, unmatched)
              false -> {:error, closing, rem, unmatched}
            end
          {:error, illegal, rem, unmatched} -> {:error, illegal, rem, unmatched}
        end
      close?(first) -> {:ok, first, rest, tl(unmatched)}
    end
  end

  def process_line(line) do
    chars = line |> String.codepoints |> Enum.chunk_every(1) |> Enum.flat_map(&(&1))
    check_syntax(chars, [])
  end

  def score_illegal() do
    read()
    |> Stream.map(&process_line/1)
    |> Stream.filter(fn {status, _, _, _} -> status == :error end)
    |> Stream.map(fn {_, illegal, _, _} -> Map.get(@points, illegal) end)
    |> Enum.sum()
  end

  def score_completion() do
    read()
    |> Stream.map(&process_line/1)
    |> Stream.filter(fn {status, _, _, _} -> status == :ok end)
    |> Stream.map(fn {_, _, _, unmatched} -> unmatched end)
    |> Enum.map(fn unmatched -> Enum.reduce(unmatched, 0, fn symbol, acc ->
        acc * 5 + Map.get(@completion_scores, symbol)
      end
    ) end)
    |> Statistics.median()
  end
end
