defmodule PowerConsumption do
  @filename "./input.txt"
  use Bitwise

  def position_counts(entry, {state, count}) do
    new_state = entry
    |> Enum.with_index()
    |> Enum.reduce(state, fn ({x, index}, state) ->
      if x == 49 do
          Map.update(state, index, 1, fn current_value ->
            current_value + 1
          end)
        else
          state
        end
      end)
    {new_state, count + 1}
  end

  def read do
    File.stream!(@filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_charlist/1)
  end

  def get_power_consumption do
    {state, count} = read()
      |> Enum.reduce({Map.new, 0}, &position_counts/2)
    total_bits = map_size(state)
    {gamma_rate, eps_rate} = state
      |> Enum.reduce({0, 0}, fn (entry, {gamma, eps}) ->
          shift = total_bits - elem(entry, 0) - 1
          case elem(entry, 1) > count / 2 do
            true -> {
              bor(gamma, 1 <<< shift),
              bor(eps, 0 <<< shift)
            }
            false -> {
              bor(gamma, 0 <<< shift),
              bor(eps, 1 <<< shift)
            }
          end
        end)
      gamma_rate * eps_rate
  end

  def bstr_2_int(bstr) do
    # Erlang must have a better way to do this!
      List.to_string(bstr)
      |> String.graphemes
      |> Enum.reverse
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index
      |> Enum.map(fn {bit, index} -> bit * :math.pow(2, index) end)
      |> Enum.sum()
  end

  def filter(entries, index, :og) when length(entries) > 1 do
    {state, count} = entries
      |> Enum.reduce({Map.new, 0}, &position_counts/2)
    entries
      |> Enum.filter(fn value ->
          # Most common value is 1
          case Map.get(state, index, 0) >= count / 2 do
            true -> Enum.at(value, index) == 49
            false -> Enum.at(value, index) == 48
          end
        end)
      |> filter(index + 1, :og)
  end

  def filter(entries, _, _) when length(entries) == 1 do
    Enum.at(entries, 0)
  end

  def filter(entries, index, :co2) when length(entries) > 1 do
    {state, count} = entries
      |> Enum.reduce({Map.new, 0}, &position_counts/2)
    entries
      |> Enum.filter(fn value ->
          case Map.get(state, index, 0) >= count / 2 do
            true -> Enum.at(value, index) == 48
            false -> Enum.at(value, index) == 49
          end
        end)
      |> filter(index + 1, :co2)
  end

  def get_life_support_rating do
    entries = read() |> Enum.map(fn x -> x end)

    og_val = entries |> filter(0, :og)
    co2s_val = entries |> filter(0, :co2)

    IO.puts("Oxygen generator rating #{og_val}")
    IO.puts("CO2 scrubber rating #{co2s_val}")

    bstr_2_int(og_val) * bstr_2_int(co2s_val)

  end
end
