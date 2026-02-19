defmodule Anoma.Client.Web.IntentsJSON do
  @spec render(String.t(), map()) :: map()
  def render("index.json", %{intents: intents}) do
    intents = Enum.map(intents, &Base.encode64/1)
    %{intents: intents}
  end

  def render("add_intent.json", _assigns) do
    %{message: "intent added"}
  end

  def render("500.json", %{error: err}) do
    %{error: err}
  end
end
