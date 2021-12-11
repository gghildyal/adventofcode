defmodule Transpose do
  def transpose([[] | _]), do: []
  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end
end

defmodule Board do
  defstruct rows: [], columns: []

  def new(rows) do
    %Board{rows: rows, columns: Transpose.transpose(rows)}
  end

  def tick(%Board{rows: rows, columns: columns}, elem) do
    new_rows = rows
      |> Enum.map(fn row -> row |> Enum.filter(
          fn e -> e != elem end)
        end)
    new_columns = columns |> Enum.map(fn row -> row |> Enum.filter(
      fn e -> e != elem end)
    end)
    %Board{rows: new_rows, columns: new_columns}
  end

  def has_won?(%Board{rows: rows, columns: columns}) do
    cond do
      rows |> Enum.map(&Enum.empty?/1) |> Enum.member?(true) -> true
      columns |> Enum.map(&Enum.empty?/1) |> Enum.member?(true) -> true
      true -> false
    end
  end
end

defmodule Bingo do
  defstruct boards: []

  @boards_file "./boards.txt"
  @draws_file "./draws.txt"

  def transform(line) do
    line |> Enum.reverse
    |> Enum.map(&String.split/1)
    |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)
  end

  def get_boards do
    File.stream!(@boards_file)
    |> Stream.map(&String.trim/1)
    |> Stream.filter(fn row -> row !== "" end)
    |> Stream.with_index(1)
    |> Enum.reduce(%{boards: [], rows: []}, fn {row, idx}, acc ->
        case rem(idx, 5) == 0 do
          true -> %{boards: [Board.new(transform([row | acc.rows])) | acc.boards], rows: []}
          false -> %{boards: acc.boards, rows: [row | acc.rows]}
        end
      end)
    |> Map.get(:boards)
    |> Enum.reverse()
  end

  def get_draws do
    File.read!(@draws_file)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def play(draws, boards) do
    [draw | rest] = draws
    {boards, winning_board} = boards
      |> Enum.map_reduce(nil, fn board, acc ->
          board = board |> Board.tick(draw)
          case Board.has_won?(board) do
            true -> {:halt, board}
            false -> {board, acc}
          end
        end)
    case winning_board == nil do
      false -> {draw, winning_board}
      true -> play(rest, boards)
    end
  end

  def play_2(draws, boards) do
      [draw | rest] = draws
      boards = boards |> Enum.map(fn board -> Board.tick(board, draw) end)
      non_winning = Enum.filter(boards, fn board -> !Board.has_won?(board) end)
      case length(non_winning) == 0 do
        true -> {draw, boards}
        false -> play_2(rest, non_winning)
      end
    end

  @spec process :: any
  def process do
    boards = get_boards()
    {draw, winning_board} = get_draws()
    |> play(boards)
    winning_board.rows |> List.flatten |> Enum.sum |> Kernel.*(draw)
  end

  def process_2 do
    boards = get_boards()
    {draw, finished} = get_draws()
    |> play_2(boards)
    last_board = finished |> List.last
    last_board.rows |> List.flatten |> Enum.sum |> Kernel.*(draw)
  end
end
