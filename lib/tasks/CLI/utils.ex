defmodule Mix.Tasks.CLI.Utils do
  def args_to_map(args) do
    args
    |> Enum.map(fn x ->
      String.split(x, "=")
      |> List.to_tuple()
      |> case do
        {k, v} -> {k, v}
        {k} -> {k, nil}
      end
    end)
    |> Enum.into(%{})
  end

  @commands_help %{
    "users" => %{optionals: "", body: "List all users"},
    "users add" => %{optionals: "", body: "Add an authorized user"},
    "users remove" => %{optionals: "", body: "Remove an authorized user"},
    "domains" => %{optionals: "", body: "List all public domains"},
    "domains add" => %{optionals: "", body: "Add a domain to the public domains list"},
    "domains remove" => %{optionals: "", body: "Remove a domain from the public domains list"}
  }

  def print_help_for(cmd) do
    IO.puts "Usage: boreale cli #{cmd} #{@commands_help[cmd].optionals}"
    IO.puts ""
    IO.puts "#{@commands_help[cmd].body}"
  end

  def print_general_help do
    IO.puts "Usage:    boreale cli COMMAND"
    IO.puts ""
    IO.puts "A CLI for managing boreale"
    IO.puts ""
    IO.puts "Commands:"
    IO.puts "  domains           #{@commands_help["domains"].body}"
    IO.puts "  domains add       #{@commands_help["domains add"].body}"
    IO.puts "  domains remove    #{@commands_help["domains remove"].body}"
    IO.puts "  users             #{@commands_help["users"].body}"
    IO.puts "  users add         #{@commands_help["users add"].body}"
    IO.puts "  users remove      #{@commands_help["users remove"].body}"
    IO.puts ""
    IO.puts "Run 'boreale cli COMMAND --help' for more information on a command."
  end
end
