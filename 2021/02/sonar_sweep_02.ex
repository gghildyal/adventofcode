defmodule SonarSweep02 do
  @filename "./input.txt"

  def process do
    {position, depth} = File.stream!(@filename)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&translate/1)
      |> Enum.reduce({0, 0}, &progress/2)
    position * depth
  end

  def progress({:forward, amount}, {position, depth}) do
    {position + amount, depth}
  end

  def progress({:up, amount}, {position, depth}) do
    {position, depth - amount}
  end

  def progress({:down, amount}, {position, depth}) do
    {position, depth + amount}
  end

  def translate(instruction) do
    [direction, amount] = String.split(instruction, " ")
    {String.to_atom(direction), String.to_integer(amount)}
  end

  def sum(entry, {window, count}) when length(window) < 3 do
    {[String.to_integer(entry) | window], count}
  end

  def sum(entry, {window, count}) when length(window) == 3 do
    new_window = [String.to_integer(entry) | Enum.take(window, 2)]
    if Enum.sum(new_window) > Enum.sum(window) do
      {new_window, count + 1}
    else
      {new_window, count}
    end
  end

  def count(entry, {last, count}) do
    case entry > last do
      true -> {entry, count + 1}
      false -> {entry, count}
    end
  end
end

defmodule SonarSweep02_2 do
  @filename "./input.txt"

  def process do
    {position, depth, _} = File.stream!(@filename)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&translate/1)
      |> Enum.reduce({0, 0, 0}, &progress/2)
    position * depth
  end

  def progress({:forward, amount}, {position, depth, aim}) do
    {position + amount, depth + aim * amount, aim}
  end

  def progress({:up, amount}, {position, depth, aim}) do
    {position, depth, aim - amount}
  end

  def progress({:down, amount}, {position, depth, aim}) do
    {position, depth, aim + amount}
  end

  def translate(instruction) do
    [direction, amount] = String.split(instruction, " ")
    {String.to_atom(direction), String.to_integer(amount)}
  end

  def sum(entry, {window, count}) when length(window) < 3 do
    {[String.to_integer(entry) | window], count}
  end

  def sum(entry, {window, count}) when length(window) == 3 do
    new_window = [String.to_integer(entry) | Enum.take(window, 2)]
    if Enum.sum(new_window) > Enum.sum(window) do
      {new_window, count + 1}
    else
      {new_window, count}
    end
  end

  def count(entry, {last, count}) do
    case entry > last do
      true -> {entry, count + 1}
      false -> {entry, count}
    end
  end
end
