defmodule ElMascarar.PageController do
  use ElMascarar.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
