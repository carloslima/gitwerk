defmodule GitWerkWeb.ChangesetView do
  use GitWerkWeb, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `GitWerk.Web.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("errors.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    #%{errors: translate_errors(changeset)}
    JaSerializer.EctoErrorSerializer.format(changeset)
  end
end
