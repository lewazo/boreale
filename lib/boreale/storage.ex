defmodule Boreale.Storage do
  def read_dets(file, match) do
    {:ok, table} =
      file
      |> String.to_atom()
      |> :dets.open_file(type: :set)

    results = :dets.match(table, match)
    :dets.close(table)
    results
  end
end
