import Config

# refresh the open api spec during development
config :open_api_spex, :cache_adapter, OpenApiSpex.Plug.NoneCache

# Enable debug errors in development
config :anoma_client, Anoma.Client.Web.Endpoint, debug_errors: true
