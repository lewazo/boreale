defmodule Boreale.Domains do
  @domains_file "data/domains.dets"

  defp all do
    {:ok, table} =
      File.cwd!()
      |> Path.join(@domains_file)
      |> String.to_atom()
      |> :dets.open_file(type: :set)

    :dets.match(table, {:"$1", :"$2"}) |> List.flatten()
  end

  def public?(domain) do
    Enum.any?(all(), fn public_domain -> domain == public_domain end)
  end
end
