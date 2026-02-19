defmodule Anoma.Client.Web.SubscribeJSON do
  @spec render(String.t(), map()) :: map()
  def render("subscribed.json", _params) do
    %{message: "subscribed"}
  end
end
