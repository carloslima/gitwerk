defmodule GitWerkWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GitWerkWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(GitWerkWeb.ChangesetView, "errors.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(GitWerkWeb.ErrorView, "error.json", error: %{title: "Resource not found"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render(GitWerkWeb.ErrorView, "error.json", error: %{title: "Not permitted to perform the requested operation"})
  end
end

