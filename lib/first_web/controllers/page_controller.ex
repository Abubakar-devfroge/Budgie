defmodule FirstWeb.PageController do
  use FirstWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

    def dash(conn, _params) do
    render(conn, :dash)
  end
end
