defmodule M2X.CollectionTest do
  use ExUnit.Case
  doctest M2X.Collection

  def mock_subject(request, response) do
    %M2X.Collection {
      client: MockEngine.client(request, response),
      attributes: test_attributes,
    }
  end

  def id do
    "0123456789abcdef0123456789abcdef"
  end

  def test_attributes do
    %{ "id"=>id, "name"=>"test", "description"=>"foo" }
  end

  def test_sub do
    Enum.at(test_sublist, 0)
  end

  def test_sublist do
    [ %{ "id"=>"a123", "name"=>"test" },
      %{ "id"=>"b123", "name"=>"test" },
      %{ "id"=>"c123", "name"=>"test" } ]
  end

  test "fetch" do
    client = MockEngine.client \
      {:get, "/v2/collections/"<>id, nil},
      {200, test_attributes, nil}
    subject = M2X.Collection.fetch(client, id)

    %M2X.Collection { } = subject
    assert subject.client == client
    assert subject.attributes == test_attributes
  end

  test "list" do
    params = %{ q: "test" }
    <<_::binary-size(1), suffix::binary>> = id
    result = %{ collections: [
      %{ id: "a"<>suffix, name: "test", description: "foo" },
      %{ id: "b"<>suffix, name: "test", description: "bar" },
      %{ id: "c"<>suffix, name: "test", description: "baz" },
    ]}
    client = MockEngine.client({:get, "/v2/collections", nil}, {200, result, nil})
    list   = M2X.Collection.list(client)
    client = MockEngine.client({:get, "/v2/collections", params}, {200, result, nil})
    list2  = M2X.Collection.list(client, params)

    for list <- [list, list2] do
      for subject = %M2X.Collection{} <- list do
        assert subject.client == client
        assert subject["name"] == "test"
      end
      assert Enum.at(list, 0)["id"] == "a"<>suffix
      assert Enum.at(list, 1)["id"] == "b"<>suffix
      assert Enum.at(list, 2)["id"] == "c"<>suffix
    end
  end

end
