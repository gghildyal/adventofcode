defmodule SonarSweep do
  @filename "./input_01.txt"

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

  def process do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({0, 0}, &count/2)
    |> elem(1)
  end

  def process_2 do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({[], 0}, &sum/2)
    |> elem(1)
  end
end
