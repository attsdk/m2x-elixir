defmodule M2X.DistributionTest do
  use ExUnit.Case
  doctest M2X.Distribution

  def mock_subject(request, response) do
    %M2X.Distribution {
      client: MockEngine.client(request, response),
      attributes: test_attributes,
    }
  end

  def id do
    "0123456789abcdef0123456789abcdef"
  end

  def test_attributes do
    %{ "id"=>id, "name"=>"test", "visibility"=>"public", "description"=>"foo" }
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
      {:get, "/v2/distributions/"<>id, nil},
      {200, test_attributes}
    subject = M2X.Distribution.fetch(client, id)

    %M2X.Distribution { } = subject
    assert subject.client == client
    assert subject.attributes == test_attributes
  end

  test "list" do
    params = %{ q: "test" }
    <<_::binary-size(1), suffix::binary>> = id
    result = %{ distributions: [
      %{ id: "a"<>suffix, name: "test", description: "foo" },
      %{ id: "b"<>suffix, name: "test", description: "bar" },
      %{ id: "c"<>suffix, name: "test", description: "baz" },
    ]}
    client = MockEngine.client({:get, "/v2/distributions", nil}, {200, result})
    list   = M2X.Distribution.list(client)
    client = MockEngine.client({:get, "/v2/distributions", params}, {200, result})
    list2  = M2X.Distribution.list(client, params)

    for list <- [list, list2] do
      for subject = %M2X.Distribution{} <- list do
        assert subject.client == client
        assert subject["name"] == "test"
      end
      assert Enum.at(list, 0)["id"] == "a"<>suffix
      assert Enum.at(list, 1)["id"] == "b"<>suffix
      assert Enum.at(list, 2)["id"] == "c"<>suffix
    end
  end

  test "devices" do
    params = %{ q: "test" }
    <<_::binary-size(1), suffix::binary>> = id
    result = %{ devices: [
      %{ id: "a"<>suffix, name: "test", description: "foo" },
      %{ id: "b"<>suffix, name: "test", description: "bar" },
      %{ id: "c"<>suffix, name: "test", description: "baz" },
    ]}
    subject  = mock_subject {:get, "/v2/distributions/"<>id<>"/devices", nil}, {200, result}
    devices  = M2X.Distribution.devices(subject)
    subject  = mock_subject {:get, "/v2/distributions/"<>id<>"/devices", params}, {200, result}
    devices2 = M2X.Distribution.devices(subject, params)

    for devices <- [devices, devices2] do
      for subject = %M2X.Device{} <- devices do
        assert subject.client == subject.client
        assert subject["name"] == "test"
      end
      assert Enum.at(devices, 0)["id"] == "a"<>suffix
      assert Enum.at(devices, 1)["id"] == "b"<>suffix
      assert Enum.at(devices, 2)["id"] == "c"<>suffix
    end
  end

  test "add_device" do
    serial = "ABC1234"
    params = %{ "serial"=>serial }
    subject = mock_subject \
      {:post, "/v2/distributions/"<>id<>"/devices", params},
      {200, test_attributes}
    device = M2X.Distribution.add_device(subject, serial)

    %M2X.Device { } = device
    assert device.client == subject.client
    assert device.attributes == test_attributes
  end

  test "triggers" do
    subject = mock_subject \
      {:get, "/v2/distributions/"<>id<>"/triggers", nil},
      {200, %{ "triggers"=>test_sublist }}

    triggers = M2X.Distribution.triggers(subject)

    for trigger = %M2X.Trigger{} <- triggers do
      assert trigger.client == subject.client
      assert trigger.under == "/distributions/"<>id
    end
    assert Enum.at(triggers, 0).attributes == Enum.at(test_sublist, 0)
    assert Enum.at(triggers, 1).attributes == Enum.at(test_sublist, 1)
    assert Enum.at(triggers, 2).attributes == Enum.at(test_sublist, 2)
  end

  test "trigger" do
    subject = mock_subject \
      {:get, "/v2/distributions/"<>id<>"/triggers/"<>test_sub["id"], nil},
      {200, test_sub}

    trigger = M2X.Distribution.trigger(subject, test_sub["id"])

    %M2X.Trigger{} = trigger
    assert trigger.client == subject.client
    assert trigger.under == "/distributions/"<>id
    assert trigger.attributes == test_sub
  end

  test "create_trigger" do
    create_attrs = %{ "id"=>test_sub["id"] }
    subject = mock_subject \
      {:post, "/v2/distributions/"<>id<>"/triggers", create_attrs},
      {201, test_sub}

    trigger = M2X.Distribution.create_trigger(subject, create_attrs)

    %M2X.Trigger{} = trigger
    assert trigger.client == subject.client
    assert trigger.under == "/distributions/"<>id
    assert trigger.attributes == test_sub
  end

end
