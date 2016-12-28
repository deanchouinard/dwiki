defmodule Dwiki.Router do
  use Plug.Router

  #  plug :opts_to_private
  plug :match
  plug :dispatch

  get "/" do
    conn
    |> IO.inspect

    conn
    |> send_resp(200, "hello")
  end

  get "/*path" do
    conn
    |> IO.inspect
    |> send_resp(200, "path: #{path}")
  end

  match _, do: send_resp(conn, 404, "not found")

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
    conn = put_private(conn, :my_app_opts, opts)
    conn = assign(conn, :my_app_opts, opts)
    super(conn, opts)
  end

end

