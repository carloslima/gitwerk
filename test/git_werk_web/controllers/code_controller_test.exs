defmodule GitWerkWeb.CodeControllerTest do
  use GitWerkWeb.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {:ok, conn: conn}
  end


  setup [:user_fixture_context, :project_fixture_context]

  test "get list of files in a repository", %{conn: conn, user: user, project: project} do
    commit_files(user.username, project.name)
    conn = conn_with_auth(conn, user)
    conn = get conn, repository_code_path(conn, :file_list, "#{user.username}/#{project.name}", "master", [])
    file_list = json_response(conn, 200)
    assert file_list
    assert length(file_list) == 2
  end


  test "get list of files in a sub dir in a repository", %{conn: conn, user: user, project: project} do
    commit_files(user.username, project.name)
    conn = conn_with_auth(conn, user)
    conn = get conn, repository_code_path(conn, :file_list, "#{user.username}/#{project.name}", "master", ["src"])
    file_list = json_response(conn, 200)
    assert file_list == [%{"name" => "code.src", "type" => "blob"}]
    assert length(file_list) == 1
  end

  test "returns 404 when repo is empty or face an error", %{conn: conn, user: user, project: project} do
    conn = conn_with_auth(conn, user)
    conn = get conn, repository_code_path(conn, :file_list, "#{user.username}/#{project.name}", "master", [])
    assert json_response(conn, 404)
  end

  def commit_files(username, repo_name) do
    {repo_clone, 0} = System.cmd("mktemp", ["-d"])
    repo_clone = String.trim(repo_clone)
    repo_remote = repo_path(username, repo_name)
    System.cmd("git", ["clone", "--quiet", repo_remote, repo_clone])
    System.cmd("touch", ["README.md"], [cd: repo_clone])
    System.cmd("mkdir", ["src"], [cd: repo_clone])
    System.cmd("touch", ["src/code.src"], [cd: repo_clone])
    System.cmd("git", ["add", "README.md"], [cd: repo_clone])
    System.cmd("git", ["add", "src"], [cd: repo_clone])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_clone])
    System.cmd("git", ["push", "origin", "HEAD"], [cd: repo_clone])
  end
end
