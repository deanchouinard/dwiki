defmodule Dwiki.Router do
  use Plug.Router

  #  plug :opts_to_private
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> IO.inspect

    page_contents =
      show_page(conn.assigns.my_app_opts[:pages_dir], "index.md")

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
    #|> send_resp(200, "hello: #{wd} \n #{page_contents}")
  end

  get "/*path" do
    page_contents =
      show_page(conn.assigns.my_app_opts[:pages_dir], path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "save/*path" do

    IO.inspect conn.params
    page_text = conn.params["page-text"]
    IO.inspect page_text
    File.write!(Path.join("pages", path), page_text)
    page_contents = show_page("pages", path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end

  post "/*path" do

    page_contents = edit_page(path)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, page_contents)
  end


  match _, do: send_resp(conn, 404, "not found")

  defp edit_page(page) do
    page_path = Path.join("pages", page)
    page_contents = File.read!(page_path)
    page_contents = EEx.eval_file("templates/edit_page.eex", [page_contents:
      page_contents, page: page])
  end

  defp show_page(pages_dir, page) do
    page_path = Path.join(pages_dir, page)
    unless File.exists?(page_path) do
      File.write!(page_path, "### #{page} \n")
    end

    page_contents = File.read!(page_path)
    page_contents = Earmark.to_html(page_contents)
    page_contents = EEx.eval_file("templates/show_page.eex", [page_contents:
      page_contents, page: page])
  end

  defp opts_to_private(conn, opts) do
    IO.inspect opts
    put_private(conn, :my_app_opts, opts)
  end

  defp dispatch(conn, opts) do
    IO.inspect opts
    super(conn, opts)
  end

  def init(opts) do
    IO.inspect opts
    super(opts)
  end

  def call(conn, opts) do
    IO.inspect opts
    #conn = put_private(conn, :my_app_opts, opts)
    conn = assign(conn, :my_app_opts, opts)
    #    conn = assign(conn, :pages_dir, opts[:pages_dir])
    super(conn, opts)
  end

end

