defmodule Mix.Tasks.CLI do
  def run([]) do Mix.Tasks.CLI.Utils.print_general_help() end
  def run([cmd | args]) do
    case cmd do
      "domains" -> domains(args)
      "users" -> users(args)
      "--help" -> Mix.Tasks.CLI.Utils.print_general_help()
      _ -> IO.puts "boreale cli: '#{cmd}' is not a boreale cli command."
           IO.puts "See 'boreale cli --help'"
    end
  end

  defp users([]) do Mix.Tasks.CLI.Users.run() end
  defp users([cmd | args]) do
    case cmd do
      "add" -> Mix.Tasks.CLI.UsersAdd.run(args)
      "remove" -> Mix.Tasks.CLI.UsersRemove.run(args)
      "--help" -> Mix.Tasks.CLI.Utils.print_help_for("users")
      _ -> IO.puts "boreale cli: 'users #{cmd}' is not a boreale cli command."
           IO.puts "See 'boreale cli --help'"
    end
  end

  defp domains([]) do Mix.Tasks.CLI.Domains.run() end
  defp domains([cmd | args]) do
    case cmd do
      "add" -> Mix.Tasks.CLI.DomainsAdd.run(args)
      "remove" -> Mix.Tasks.CLI.DomainsRemove.run(args)
      "--help" -> Mix.Tasks.CLI.Utils.print_help_for("domains")
      _ -> IO.puts "boreale cli: 'domains #{cmd}' is not a boreale cli command."
           IO.puts "See 'boreale cli --help'"
    end
  end
end
