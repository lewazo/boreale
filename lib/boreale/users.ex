defmodule Boreale.Users do
  use GenServer

  alias Boreale.Storage
  require Logger

  defmodule State do
    defstruct file: nil, users: []

    def valid?(%State{users: []}), do: false

    def valid?(%State{}, username, password)
        when is_nil(username) or is_nil(password),
        do: false

    def valid?(%State{users: users}, username, password) do
      case Map.get(users, username) do
        nil ->
          false

        password_hash ->
          validate_password(password, password_hash)
      end
    end

    defp validate_password(password, password_hash) do
      Bcrypt.verify_pass(password, password_hash)
    end

    def new(file), do: %State{file: file}
  end

  @dets_file "data/users.dets"
  def start_link(_opts \\ []) do
    file = Path.join(File.cwd!(), @dets_file)

    GenServer.start(__MODULE__, %{file: file}, name: __MODULE__)
  end

  def valid?(username, password) do
    GenServer.call(__MODULE__, {:validate, username, password})
  end

  def sync do
    GenServer.cast(__MODULE__, :sync)
  end

  def init(%{file: file}) do
    sync()
    log(:info, "Starting users server")
    {:ok, State.new(file)}
  end

  def handle_call({:validate, username, password}, _from, state) do
    {:reply, State.valid?(state, username, password), state}
  end

  def handle_cast(:sync, %State{file: file} = state) do
    users = read_from_dets(state)
    log(:info, "Read #{length(Map.keys(users))} users from dets #{file}")

    {:noreply, %State{state | users: users}}
  end

  defp read_from_dets(%State{file: file}) do
    file
    |> Storage.read_dets({:"$1", :"$2", :"$3"})
    |> Enum.map(fn x -> List.to_tuple(x) end)
    |> Enum.map(fn {u, pw, _} -> {u, pw} end)
    |> Enum.into(%{})
  end

  defp log(:info, message), do: Logger.info("[#{inspect(__MODULE__)}] #{message}")
end
