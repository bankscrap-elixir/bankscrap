defmodule Bankscrap do
  @moduledoc """
  Documentation for Bankscrap.
  """

  use HTTPoison.Base

  @default_opts [follow_redirect: true]

  def get(url, headers \\ [], params \\ %{}) do
    url_with_params = add_params_to_url(url, params)
    do_request(:get, url_with_params, headers, params)
  end

  defp do_request(method, url, headers, params) do
    request!(method, url, headers, params, @default_opts) |> process_response
  end

  def process_response(%HTTPoison.Response{status_code: 200, body: body}),
    do: body

  def process_response(%HTTPoison.Response{status_code: status_code, body: body}),
      do: {status_code, body}

  @spec process_response_body(binary) :: term
  def process_response_body(""), do: nil
  def process_response_body(body), do: Poison.decode!(body)

  @doc """
  Take an existing URI and add addition params, appending and replacing as necessary
  ## Examples
      iex> add_params_to_url("http://example.com/wat", [])
      "http://example.com/wat"
      iex> add_params_to_url("http://example.com/wat", [q: 1])
      "http://example.com/wat?q=1"
      iex> add_params_to_url("http://example.com/wat", [q: 1, t: 2])
      "http://example.com/wat?q=1&t=2"
      iex> add_params_to_url("http://example.com/wat", %{q: 1, t: 2})
      "http://example.com/wat?q=1&t=2"
      iex> add_params_to_url("http://example.com/wat?q=1&t=2", [])
      "http://example.com/wat?q=1&t=2"
      iex> add_params_to_url("http://example.com/wat?q=1", [t: 2])
      "http://example.com/wat?q=1&t=2"
      iex> add_params_to_url("http://example.com/wat?q=1", [q: 3, t: 2])
      "http://example.com/wat?q=3&t=2"
      iex> add_params_to_url("http://example.com/wat?q=1&s=4", [q: 3, t: 2])
      "http://example.com/wat?q=3&s=4&t=2"
      iex> add_params_to_url("http://example.com/wat?q=1&s=4", %{q: 3, t: 2})
      "http://example.com/wat?q=3&s=4&t=2"
  """
  @spec add_params_to_url(binary, list) :: binary
  def add_params_to_url(url, params) do
    url
    |> URI.parse()
    |> merge_uri_params(params)
    |> String.Chars.to_string()
  end

  @spec merge_uri_params(URI.t(), list) :: URI.t()
  defp merge_uri_params(uri, []), do: uri

  defp merge_uri_params(%URI{query: nil} = uri, params)
       when is_list(params) or is_map(params) do
    uri
    |> Map.put(:query, URI.encode_query(params))
  end

  defp merge_uri_params(%URI{} = uri, params)
       when is_list(params) or is_map(params) do
    uri
    |> Map.update!(:query, fn q ->
         q
         |> URI.decode_query()
         |> Map.merge(param_list_to_map_with_string_keys(params))
         |> URI.encode_query()
       end)
  end

  @spec param_list_to_map_with_string_keys(list) :: map
  defp param_list_to_map_with_string_keys(list)
       when is_list(list) or is_map(list) do
    for {key, value} <- list, into: Map.new() do
      {"#{key}", value}
    end
  end
end
