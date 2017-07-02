defmodule Gitwerk.Web.RepositoryControllerTest do
  use Gitwerk.Web.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "list of repositories with invalid jwt token", %{conn: conn} do
    conn = conn |> put_req_header("authorization", "Bearer FOOBARBUZ")
    conn = get conn, repository_path(conn, :index)

    assert json_response(conn, 401) == %{"errors" => %{"authentication" => "field required in header"}}
  end

  test "list of repositories", %{conn: conn} do
    user = user_fixture()
    conn = conn_with_auth(conn, user)
    conn = get conn, repository_path(conn, :index)

    assert json_response(conn, 200)
  end

  test "creates repository for user", %{conn: conn} do
    user = user_fixture()
    conn =
      conn
      |> conn_with_auth(user)
      |> post(repository_path(conn, :create), [repository: %{name: "my-repo", privacy: :public}])

    assert %{"id" => _} = json_response(conn, 201)
  end

  test "gets a repository by it's name for auth user", %{conn: conn} do
    user = user_fixture()
    repository = repository_fixture(user_id: user.id)
    conn = conn_with_auth(conn, user)
    conn = get conn, user_repository_path(conn, :show, user.username, repository.name)
    assert %{"id" => _, "user" => %{}} = json_response(conn, 200)
  end

  test "gets a repository that is private without auth", %{conn: conn} do
    user = user_fixture()
    repository = repository_fixture(user_id: user.id, privacy: :private)
    conn = get conn, user_repository_path(conn, :show, user.username, repository.name)
    assert json_response(conn, 404)
  end


  test "gets a private repository for auth user", %{conn: conn} do
    user = user_fixture()
    repository = repository_fixture(user_id: user.id, privacy: :private)
    conn = conn_with_auth(conn, user)
    conn = get conn, user_repository_path(conn, :show, user.username, repository.name)
    assert %{"id" => _} = json_response(conn, 200)
  end
end
