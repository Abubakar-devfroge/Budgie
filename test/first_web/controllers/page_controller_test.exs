defmodule FirstWeb.PageControllerTest do
  use FirstWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Accelerate Productivity"
  end
end
