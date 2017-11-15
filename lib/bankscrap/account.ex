defmodule Bankscrap.Account do
  defstruct [
    :bank,
    :id,
    :name,
    :balance,
    :available_balance,
    :currency,
    :description,
    :transactions,
    :iban,
    :bic,
    :raw_data
  ]
end
