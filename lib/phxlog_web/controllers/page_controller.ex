defmodule PhxlogWeb.PageController do
  use PhxlogWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
