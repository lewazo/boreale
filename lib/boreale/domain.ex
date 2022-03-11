defmodule Boreale.Domain do
  alias __MODULE__

  defstruct host: nil, created_at: nil

  def dets_domain_to_struct(domains) do
    Enum.map(domains, fn [host, created_at] ->
      %Domain{
        host: host,
        created_at: created_at
      }
    end)
  end
end
