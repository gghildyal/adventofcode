defmodule SyntaxChecker do
  @filename "./test_input.txt"
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

  def check_syntax(line) when length(line) == 0 do
    {:ok, nil , []}
  end

  def check_syntax(line) do
    [first | rest] = line
    cond do
      open?(first) ->
        case check_syntax(rest) do
          {:ok, nil, rem} -> {:ok, nil, rest}
          {:ok, closing, rem} ->
            case pair?(first, closing) do
              true -> check_syntax(rem)
              false -> {:error, closing, rem}
            end
          {:error, illegal, rem} -> {:error, illegal, rem}
        end
      close?(first) -> {:ok, first, rest}
    end
  end

  def process_line(line) do
    chars = line |> String.codepoints |> Enum.chunk_every(1) |> Enum.flat_map(&(&1))
    check_syntax(chars)
  end

  def score_illegal() do
    read()
    |> Enum.map(&process_line/1)
    |> Enum.filter(fn {status, illegal, _} -> status == :error end)
    |> Enum.map(fn {_, illegal, _} -> Map.get(@points, illegal) end)
    |> Enum.sum()
  end

  def score_completion() do
    read()
    |> Enum.map(&process_line/1)
    |> Enum.filter(fn {status, illegal, _} -> status == :ok end)
  end
end
