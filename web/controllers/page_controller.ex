defmodule Identity.PageController do
  use Identity.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
