defmodule FirstWeb.PageController do
  use FirstWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
