defmodule Boreale.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case
      import Mock
    end
  end
end
