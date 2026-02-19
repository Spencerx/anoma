defmodule Anoma.Client.Web.TransactionJSON do
  @spec render(String.t(), map()) :: map()
  def render("composed.json", %{transaction: transaction}) do
    %{transaction: Base.encode64(transaction)}
  end

  def render("verified.json", %{valid?: valid?}) do
    %{valid?: valid?}
  end
end
