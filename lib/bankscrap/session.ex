defmodule Bankscrap.Session do
  defstruct [:cookies, :data]

  def create_session_from_headers(headers) do
    cookies =
      Enum.filter(headers, fn
        {"Set-Cookie", _} -> true
        _ -> false
      end)

    %__MODULE__{cookies: cookies}
  end
end
