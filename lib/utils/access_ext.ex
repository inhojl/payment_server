defmodule Utils.AccessExt do

  def fetch_in(term, [key | next_keys]) do
    case Access.fetch(term, key) do
      {:ok, inner_term} -> fetch_in(inner_term, next_keys)
      :error -> {:error, key}
    end
  end

  def fetch_in(term, []) do
    {:ok, term}
  end

end
