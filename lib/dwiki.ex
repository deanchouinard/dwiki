defmodule Dwiki do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.get_env(:dwiki, :cowboy_port, 4000)

    pages_dir = case Mix.env do
      :test ->
        Path.join(File.cwd!(), "test/pages")
      _ ->
        Path.join(File.cwd!(), "pages")
    end
    
    unless File.exists?(pages_dir) do
      File.mkdir!(pages_dir)
    end

    dparams = [ test: "test", pages_dir: pages_dir ]

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Dwiki.Worker.start_link(arg1, arg2, arg3)
      # worker(Dwiki.Worker, [arg1, arg2, arg3]),
      Plug.Adapters.Cowboy.child_spec(:http, Dwiki.Router, dparams,
        port: port)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dwiki.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
