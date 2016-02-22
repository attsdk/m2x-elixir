# Common tests for modules with M2X.Resource behaviour
defmodule M2X.ResourceTest.Common do
  defmacro __using__(opts) do
    {:ok, mod} = Keyword.fetch(opts, :mod)

    quote location: :keep do
      alias unquote(mod), as: TheModule

      def test_attributes do
        Map.merge required_attrs,
          %{ "foo"=>88, "bar"=>"ninety-nine" }
      end

      def new_test_attributes do
        Map.merge required_attrs,
          %{ "foo"=>99, "bar"=>"eighty-eight", "baz"=>true }
      end

      def mock_subject(request, response) do
        %TheModule {
          client: MockEngine.client(request, response),
          attributes: test_attributes,
        }
      end

      test "attribute access" do
        subject = %TheModule { attributes: test_attributes }

        assert subject.attributes == test_attributes
        assert subject["foo"]     == test_attributes["foo"]
        assert subject["bar"]     == test_attributes["bar"]
      end

      test "create!/1" do
        client = MockEngine.client \
          {:post, main_path, %{}},
          {204, new_test_attributes, nil}
        {:ok, subject} = TheModule.create!(client)

        assert subject.client     == client
        assert subject.attributes == new_test_attributes
      end

      test "create!/2" do
        client = MockEngine.client \
          {:post, main_path, test_attributes},
          {204, new_test_attributes, nil}
        {:ok, subject} = TheModule.create!(client, test_attributes)

        %TheModule { } = subject
        assert subject.client     == client
        assert subject.attributes == new_test_attributes
      end

      test "refreshed" do
        subject = mock_subject \
          {:get, path, nil},
          {200, new_test_attributes, nil}
        assert subject.attributes == test_attributes
        {:ok, new_subject} = TheModule.refreshed(subject)

        %TheModule { } = new_subject
        assert new_subject.client == subject.client
        assert new_subject.attributes == new_test_attributes
      end

      test "update!" do
        subject = mock_subject \
          {:put, path, new_test_attributes},
          {204, nil, nil}

        {:ok, res} = TheModule.update!(subject, new_test_attributes)
        assert res.status == 204
      end

      test "delete!" do
        subject = mock_subject \
          {:delete, path, nil},
          {204, nil, nil}

        {:ok, res} = TheModule.delete!(subject)
        assert res.status == 204
      end

    end
  end
end

defmodule M2X.ResourceTest.Device do
  use ExUnit.Case
  use M2X.ResourceTest.Common, mod: M2X.Device
  doctest M2X.Device

  def id             do "0123456789abcdef0123456789abcdef" end
  def main_path      do "/v2/devices"                      end
  def path           do main_path<>"/"<>id                 end
  def required_attrs do %{ "id" => id }                    end
end

defmodule M2X.ResourceTest.Distribution do
  use ExUnit.Case
  use M2X.ResourceTest.Common, mod: M2X.Distribution
  doctest M2X.Distribution

  def id             do "0123456789abcdef0123456789abcdef" end
  def main_path      do "/v2/distributions"                end
  def path           do main_path<>"/"<>id                 end
  def required_attrs do %{ "id" => id }                    end
end

defmodule M2X.ResourceTest.Collection do
  use ExUnit.Case
  use M2X.ResourceTest.Common, mod: M2X.Collection
  doctest M2X.Collection

  def id             do "0123456789abcdef0123456789abcdef" end
  def main_path      do "/v2/collections"                  end
  def path           do main_path<>"/"<>id                 end
  def required_attrs do %{ "id" => id }                    end
end

defmodule M2X.ResourceTest.Key do
  use ExUnit.Case
  use M2X.ResourceTest.Common, mod: M2X.Key
  doctest M2X.Key

  def key            do "0123456789abcdef0123456789abcdef" end
  def main_path      do "/v2/keys"                         end
  def path           do main_path<>"/"<>key                end
  def required_attrs do %{ "key" => key }                  end
end
