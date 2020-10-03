defmodule Boreale.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case
      use Plug.Test
      import Mock
      import Boreale.ConnCase
    end
  end
end
