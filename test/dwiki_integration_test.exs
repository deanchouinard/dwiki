defmodule DwikiIntegrationTest do
  use ExUnit.Case
  use Plug.Test

  doctest Dwiki

  test "shows index.md page" do
    response = HTTPoison.get! "http://localhost:4000/"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "hello"

  end

  test "edit and save a page" do
    response = HTTPoison.get! "http://localhost:4000/first.md"

    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response

    response = HTTPoison.post! "http://localhost:4000/first.md",
    "{\"body\": \"body\"}", [{"Content-Type", "application/x-www-form-urlencoded"}]
    #"{\"body\": \"body\"}"
    assert %HTTPoison.Response{status_code: 200} = response
    %HTTPoison.Response{body: body} = response
    #    body = body <> "edit"

    IO.inspect response

    response = HTTPoison.post! "http://localhost:4000/save/first.md",
    {:form, [pagetext: "edit"]}, [{"Content-Type", "application/x-www-form-urlencoded"}]
    assert %HTTPoison.Response{status_code: 200} = response
    assert %HTTPoison.Response{body: body} = response
    assert body =~ "edit"
  end

end

