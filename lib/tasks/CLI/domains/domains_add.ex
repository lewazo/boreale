defmodule Mix.Tasks.CLI.DomainsAdd do
  def run(args) do
    args = Mix.Tasks.CLI.Utils.args_to_map(args)

    case args do
      %{"--help" => _} -> Mix.Tasks.CLI.Utils.print_help_for("domains add")
      x when x == %{} -> add_domain()
      _ -> IO.puts "boreale cli: domains add command does not take any arguments"
           IO.puts "See 'boreale cli domains add --help'"
    end
  end

  defp add_domain do
    domain = IO.gets("Public domain name (FQDN): ") |> String.trim

    if (String.length(domain) >= 0) do
      case insert_domain(domain) do
       {:ok} -> IO.puts "Public domain #{domain} has been added."
       {:error, msg} -> IO.puts msg
      end
    else
      IO.puts "Domain can't be empty."
    end
  end

  defp insert_domain(domain) do
    date_time = DateTime.utc_now()
    {:ok, table} =
      File.cwd!
      |> Path.join("data/domains.dets")
      |> String.to_atom()
      |> :dets.open_file([type: :set])

    created? = :dets.insert_new(table, {domain, date_time})
    :dets.close(table)

    if created?, do: {:ok}, else: {:error, "The public domain #{domain} already exists."}
  end
end
