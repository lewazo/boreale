defmodule Boreale.Tasks.Cli.Domains do
  alias Boreale.Storage

  def run do
    {:ok, table} = :dets.open_file(Storage.persisted_domains_filepath(), type: :set)

    domains =
      :dets.match(table, {:"$1", :"$2"})
      |> Stream.map(fn x -> List.to_tuple(x) end)
      |> Enum.sort(fn {_, x}, {_, y} -> DateTime.compare(x, y) == :lt end)
      |> Enum.map_reduce(1, fn x, acc ->
        {Tuple.insert_at(x, 0, Integer.to_string(acc)), acc + 1}
      end)
      |> elem(0)
      |> Enum.map(fn {id, d, dt} -> {id, d, DateTime.to_string(dt)} end)

    :dets.close(table)

    if length(domains) > 0 do
      print_table(domains)
      domains
    else
      IO.puts("There are no public domains configured.")
      nil
    end
  end

  defp print_table(domains) do
    rows =
      [["ID", "DOMAIN", "CREATED AT (UTC)"]] ++ Enum.map(domains, fn x -> Tuple.to_list(x) end)

    number_of_cols = length(Enum.at(rows, 0))

    lengths_of_longest_strings =
      Enum.reduce(0..(number_of_cols - 1), %{}, fn col, acc_col ->
        longest_str_for_col =
          Enum.reduce(rows, 0, fn row, acc_row ->
            str_length = String.length(Enum.at(row, col))
            if str_length > acc_row, do: str_length, else: acc_row
          end)

        Map.put(acc_col, col, longest_str_for_col)
      end)

    Enum.each(rows, fn row ->
      Stream.with_index(row)
      |> Enum.each(fn {col, idx} ->
        IO.write(col)
        spacing = lengths_of_longest_strings[idx] - String.length(col)
        Enum.each(0..(spacing + 2), fn _ -> IO.write(" ") end)
      end)

      IO.puts("")
    end)
  end
end
