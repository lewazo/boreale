defmodule Boreale.Domains do
  use GenServer

  require Logger

  defmodule State do
    defstruct file: nil, domains: []

    def public?(%State{domains: domains}, domain), do: domain in domains

    def new(file), do: %State{file: file}
  end

  @fallback_file "data/domains.dets"
  def start_link(opts) do
    file = Keyword.get(opts, :file, @fallback_file)

    GenServer.start(__MODULE__, %{file: file}, name: __MODULE__)
  end

  def public?(domain) do
    GenServer.call(__MODULE__, {:public, domain})
  end

  def sync do
    GenServer.cast(__MODULE__, :sync)
  end

  def init(%{file: file}) do
    send(self(), :sync)
    log(:info, "Starting domains server ")
    {:ok, State.new(file)}
  end

  def handle_call({:public, domain}, _from, state) do
    {:reply, State.public?(state, domain), state}
  end

  def handle_cast(:sync, state) do
    domains = read_from_dets(state)

    {:noreply, %State{state | domains: domains}}
  end

  defp read_from_dets(%State{file: file}) do
    {:ok, table} =
      file
      |> String.to_atom()
      |> :dets.open_file(type: :set)

    :dets.match(table, {:"$1", :"$2"}) |> List.flatten()
  end

  # defp all do
  #   {:ok, table} =
  #     File.cwd!()
  #     |> Path.join(@domains_file)
  #     |> String.to_atom()
  #     |> :dets.open_file(type: :set)

  #   :dets.match(table, {:"$1", :"$2"}) |> List.flatten()
  # end

  # def public?(domain) do
  #   Enum.any?(all(), fn public_domain -> domain == public_domain end)
  # end

  def log(type, message) do
    apply(Logger, type, ["[#{inspect(__MODULE__)}] #{message}"])
  end
end
