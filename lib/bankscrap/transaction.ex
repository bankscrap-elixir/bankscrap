defmodule Bankscrap.Transaction do
  defstruct [
    :id,
    :amount,
    :description,
    :effective_date,
    :operation_date,
    :balance,
    :account
  ]
end
