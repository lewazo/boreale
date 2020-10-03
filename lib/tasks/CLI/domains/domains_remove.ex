defmodule Mix.Tasks.Cli.DomainsRemove do
  alias Mix.Tasks.Cli

  def run(args) do
    args = Cli.Utils.args_to_map(args)

    case args do
      %{"--help" => _} ->
        Cli.Utils.print_help_for("domains remove")

      x when x == %{} ->
        remove_domain()

      _ ->
        IO.puts("boreale cli: domains remove command does not take any arguments")
        IO.puts("See 'boreale cli domains remove --help'")
    end
  end

  defp remove_domain do
    domains = Cli.Domains.run()

    with {:domains_not_empty} <- is_domains_empty?(domains),
         {:ok, domain_name} <- get_domain(domains) do
      {:ok, table} =
        File.cwd!()
        |> Path.join("data/domains.dets")
        |> String.to_atom()
        |> :dets.open_file(type: :set)

      deleted? = :dets.delete(table, domain_name)
      :dets.close(table)

      case deleted? do
        :ok -> IO.puts("Public domain #{domain_name} has been removed.")
        _ -> IO.puts("Error : Public domain #{domain_name} hasn't been removed.")
      end
    else
      {:no_domain_with_id} -> IO.puts("Error: There is no public domain with this ID.")
      {:domains_empty} -> nil
    end
  end

  defp get_domain(domains) do
    domains =
      Stream.map(domains, fn {id, name, _} -> {id, name} end)
      |> Enum.into(%{})

    IO.puts("")
    id = IO.gets("Enter the ID of the public domain you wish to remove: ") |> String.trim()

    if domains[id],
      do: {:ok, domains[id]},
      else: {:no_domain_with_id}
  end

  defp is_domains_empty?(domains) do
    case is_nil(domains) do
      true -> {:domains_empty}
      false -> {:domains_not_empty}
    end
  end
end
