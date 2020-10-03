defmodule Boreale.Storage do
  def read_dets(file, match) do
    {:ok, table} =
      file
      |> String.to_atom()
      |> :dets.open_file(type: :set)

    :dets.match(table, match)
  end
end
