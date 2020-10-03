defmodule Boreale.Domains do
  use GenServer

  alias Boreale.Storage
  require Logger

  defmodule State do
    defstruct file: nil, domains: []

    def public?(%State{domains: domains}, domain), do: domain in domains

    def new(file), do: %State{file: file}
  end

  @dets_file "data/domains.dets"
  def start_link(_opts \\ []) do
    file = Path.join(File.cwd!(), @dets_file)

    GenServer.start(__MODULE__, %{file: file}, name: __MODULE__)
  end

  def public?(domain) do
    GenServer.call(__MODULE__, {:public, domain})
  end

  def sync do
    GenServer.cast(__MODULE__, :sync)
  end

  def init(%{file: file}) do
    sync()
    log(:info, "Starting domains server ")
    {:ok, State.new(file)}
  end

  def handle_call({:public, domain}, _from, state) do
    {:reply, State.public?(state, domain), state}
  end

  def handle_cast(:sync, %State{file: file} = state) do
    domains = read_from_dets(state)
    log(:info, "Read #{length(domains)} from dets #{file}")

    {:noreply, %State{state | domains: domains}}
  end

  defp read_from_dets(%State{file: file}) do
    file
    |> Storage.read_dets({:"$1", :"$2"})
    |> Enum.reduce([], fn [domain | _], acc -> [domain | acc] end)
  end

  defp log(:info, message), do: Logger.info("[#{inspect(__MODULE__)}] #{message}")
end
