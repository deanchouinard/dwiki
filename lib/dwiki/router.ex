defmodule Dwiki.Router do
  use Plug.Router

  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get "/" do
    page_contents =
      show_page(conn.assigns.my_app_opts[:pages_dir], "index.md")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  get "/*path" do
    page_contents =
      show_page(conn.assigns.my_app_opts[:pages_dir], path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "/search" do
    page_text = conn.params["stext"]
    page_contents = search_results(conn.assigns.my_app_opts[:pages_dir], page_text)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "save/*path" do

    page_path = conn.assigns.my_app_opts[:pages_dir]
    page_text = conn.params["pagetext"]
    File.write!(Path.join(page_path, path), page_text)
    page_contents = show_page(page_path, path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "/*path" do

    page_contents = edit_page(conn.assigns.my_app_opts[:pages_dir],  path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  match _, do: send_resp(conn, 404, "not found")

  defp search_results(pages_dir, stext) do
    IO.puts "search_results"
    ##System.cmd("ack", [stext], cd: pages_dir)
    Enum.map(File.ls!(pages_dir), fn(x) -> search_file(pages_dir, x,
    stext) end)
    |> IO.inspect
  end

  defp search_file(pages_dir, file, stext) do
    File.stream!(Path.join(pages_dir, file))
    |> Enum.filter(&(String.contains?(&1, stext)))
    |> Enum.map(&(make_link(&1, file)))
  end

  defp make_link(match, file) do
    "<a href=#{file}>#{match}</a> #{file}</br>"
    end

  defp edit_page(pages_dir, page) do
    page_path = Path.join(pages_dir, page)
    page_contents = File.read!(page_path)
    build_page("templates/edit_page.eex", {page_contents, page})
  end

  defp show_page(pages_dir, page) do
    page_path = Path.join(pages_dir, page)
    unless File.exists?(page_path) do
      File.write!(page_path, "### #{page} \n")
    end

    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    build_page("templates/show_page.eex", {page_contents, page})

  end

  defp build_page(template, {page_contents, page} = _vars) do
    EEx.eval_file("templates/app.eex", [body:
      EEx.eval_file(template, [page_contents: page_contents, page: page])
    ])
  end

  def call(conn, opts) do
    conn = assign(conn, :my_app_opts, opts)
    super(conn, opts)
  end

end

