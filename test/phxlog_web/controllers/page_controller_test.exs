defmodule PhxlogWeb.PageControllerTest do
  use PhxlogWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "All Blogs"
  end
end
