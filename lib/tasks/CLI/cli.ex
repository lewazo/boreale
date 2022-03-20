defmodule Boreale.Tasks.Cli do
  alias __MODULE__

  @moduledoc "Provides a CLI for basic configuration of Boreale"
  def run(string) when is_binary(string) do
    string
    |> String.split()
    |> run()
  end

  def run([]), do: Cli.Utils.print_general_help()

  def run([cmd | args]) do
    case cmd do
      "domains" ->
        domains(args)

      "users" ->
        users(args)

      "--help" ->
        Cli.Utils.print_general_help()

      _ ->
        IO.puts("boreale cli: '#{cmd}' is not a boreale cli command.")
        IO.puts("See 'boreale cli --help'")
    end
  end

  defp users([]) do
    Cli.Users.run()
  end

  defp users([cmd | args]) do
    case cmd do
      "add" ->
        Cli.UsersAdd.run(args)

      "remove" ->
        Cli.UsersRemove.run(args)

      "--help" ->
        Cli.Utils.print_help_for("users")

      _ ->
        IO.puts("boreale cli: 'users #{cmd}' is not a boreale cli command.")
        IO.puts("See 'boreale cli --help'")
    end
  end

  defp domains([]) do
    Cli.Domains.run()
  end

  defp domains([cmd | args]) do
    case cmd do
      "add" ->
        Cli.DomainsAdd.run(args)

      "remove" ->
        Cli.DomainsRemove.run(args)

      "--help" ->
        Cli.Utils.print_help_for("domains")

      _ ->
        IO.puts("boreale cli: 'domains #{cmd}' is not a boreale cli command.")
        IO.puts("See 'boreale cli --help'")
    end
  end
end
