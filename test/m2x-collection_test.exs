defmodule M2X.CollectionTest do
  use ExUnit.Case
  doctest M2X.Collection

  def mock_subject(request, response) do
    %M2X.Collection {
      client: MockEngine.client(request, response),
      attrs: test_attrs,
    }
  end

  def id do
    "0123456789abcdef0123456789abcdef"
  end

  def test_attrs do
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
      {200, test_attrs, nil}
    {:ok, subject} = M2X.Collection.fetch(client, id)

    %M2X.Collection { } = subject
    assert subject.client == client
    assert subject.attrs == test_attrs
  end

  test "metadata" do
    subject = mock_subject \
      {:get, "/v2/collections/"<>id<>"/metadata", nil},
      {200, test_sub, nil}

    {:ok, res} = M2X.Collection.metadata(subject)
    assert res.json == test_sub
  end

  test "update_metadata" do
    subject = mock_subject \
      {:put, "/v2/collections/"<>id<>"/metadata", test_sub},
      {202, nil, nil}

    {:ok, res} = M2X.Collection.update_metadata(subject, test_sub)
    assert res.status == 202
  end

  test "get_metadata_field" do
    subject = mock_subject \
      {:get, "/v2/collections/"<>id<>"/metadata/field_name", nil},
      {200, test_sub, nil}

    {:ok, res} = M2X.Collection.get_metadata_field(subject, "field_name")
    assert res.json == test_sub
  end

  test "set_metadata_field" do
    subject = mock_subject \
      {:put, "/v2/collections/"<>id<>"/metadata/field_name", %{ "value" => "field_value" }},
      {202, nil, nil}

    {:ok, res} = M2X.Collection.set_metadata_field(subject, "field_name", "field_value")
    assert res.status == 202
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
    {:ok, list}  = M2X.Collection.list(client)

    client = MockEngine.client({:get, "/v2/collections", params}, {200, result, nil})
    {:ok, list2} = M2X.Collection.list(client, params)

    for list <- [list, list2] do
      for subject = %M2X.Collection{} <- list do
        assert subject.client == client
        assert subject.attrs["name"] == "test"
      end
      assert Enum.at(list, 0).attrs["id"] == "a"<>suffix
      assert Enum.at(list, 1).attrs["id"] == "b"<>suffix
      assert Enum.at(list, 2).attrs["id"] == "c"<>suffix
    end
  end

  test "add_device" do
    device_id = "0123456789abcdef0123456789abcdef"
    subject = mock_subject \
      {:put, "/v2/collections/"<>id<>"/devices/"<>device_id, %{}},
      {204, nil, nil}

    {:ok, res} = M2X.Collection.add_device(subject, device_id, %{})
    assert res.status == 204
  end

  test "remove_device" do
    device_id = "0123456789abcdef0123456789abcdef"
    subject = mock_subject \
      {:delete, "/v2/collections/"<>id<>"/devices/"<>device_id, %{}},
      {204, nil, nil}

    {:ok, res} = M2X.Collection.remove_device(subject, device_id, %{})
    assert res.status == 204
  end

end
