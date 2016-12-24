# Dwiki

A notebook wiki to store my notes.

Based upon Ward Cunningham's and Bo Leuf's Quickwiki in the book:


### Future
Turn into a "bliki".

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `dwiki` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:dwiki, "~> 0.1.0"}]
    end
    ```

  2. Ensure `dwiki` is started before your application:

    ```elixir
    def application do
      [applications: [:dwiki]]
    end
    ```

