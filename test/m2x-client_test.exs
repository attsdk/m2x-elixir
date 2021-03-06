defmodule M2X.ClientTest do
  use ExUnit.Case
  doctest M2X.Client

  test "user_agent" do
    assert Regex.match? ~r"\AM2X-Elixir/\S+ elixir/\S+ erlang/\S+ \(.*\)",
      M2X.Client.user_agent
  end

  test "default struct values" do
    subject = %M2X.Client { }
    assert subject.api_base    == "https://api-m2x.att.com"
    assert subject.api_version == :v2
    assert subject.api_key     == nil
  end

  test "get /status from real service (without mocking)" do
    subject = %M2X.Client { api_key: "0123456789abcdef0123456789abcdef" }
    {:ok, res} = M2X.Client.get(subject, "/status")

    assert res.headers == Map.merge(res.headers, %{})
    assert res.headers["Content-Type"] == "application/json; charset=UTF-8"
    assert res.json == Map.merge(res.json, %{})
    assert res.json["api"]      == "OK"
    assert res.json["triggers"] == "OK"
    assert res.status           == 200
  end

  test "get /status from mock service" do
    subject = MockEngine.client(
      {:get, "/v2/status", nil},
      {200, %{ api: "OK", triggers: "OK" }, nil}
    )
    {:ok, res} = M2X.Client.get(subject, "/status")

    assert res.headers == Map.merge(res.headers, %{})
    assert res.headers["Content-Type"] == "application/json; charset=UTF-8"
    assert res.json == Map.merge(res.json, %{})
    assert res.json["api"]      == "OK"
    assert res.json["triggers"] == "OK"
    assert res.status           == 200
  end

  test "get /status from mock service with error" do
    subject = MockEngine.client(
      {:get, "/v2/status", nil},
      {503, %{ api: "DOWN", triggers: "DOWN" }, nil}
    )
    {:error, res} = M2X.Client.get(subject, "/status")

    assert res.headers == Map.merge(res.headers, %{})
    assert res.headers["Content-Type"] == "application/json; charset=UTF-8"
    assert res.json == Map.merge(res.json, %{})
    assert res.json["api"]      == "DOWN"
    assert res.json["triggers"] == "DOWN"
    assert res.status           == 503
  end

end
