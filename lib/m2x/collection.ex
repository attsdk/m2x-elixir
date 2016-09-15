defmodule M2X.Collection do
  @moduledoc """
    Wrapper for the AT&T M2X Collection API.
    https://m2x.att.com/developer/documentation/v2/collections
  """
  use M2X.Resource, path: {"/collections", :id}

  @doc """
    Retrieve a view of the Collection associated with the given unique id.

    https://m2x.att.com/developer/documentation/v2/collections#View-Collection-Details
  """
  def fetch(client = %M2X.Client{}, id) do
    case M2X.Client.get(client, path(id)) do
      {:ok, res} -> {:ok, %M2X.Collection { client: client, attrs: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Get the custom metadata for the specified Collection.

    https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata
  """
  def metadata(coll = %M2X.Collection { client: client }) do
    M2X.Client.get(client, path(coll)<>"/metadata")
  end

  @doc """
    Update the custom metadata for the specified Collection.

    https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata
  """
  def update_metadata(coll = %M2X.Collection { client: client }, params) do
    M2X.Client.put(client, path(coll)<>"/metadata", params)
  end

  @doc """
    Get the custom metadata for the specified Collection.

    https://m2x.att.com/developer/documentation/v2/collections#Read-Collection-Metadata-Field
  """
  def get_metadata_field(coll = %M2X.Collection { client: client }, name) do
    M2X.Client.get(client, path(coll)<>"/metadata/"<>name)
  end

  @doc """
    Update the custom metadata for the specified Collection.

    https://m2x.att.com/developer/documentation/v2/collections#Update-Collection-Metadata-Field
  """
  def set_metadata_field(coll = %M2X.Collection { client: client }, name, value) do
    M2X.Client.put(client, path(coll)<>"/metadata/"<>name, %{ "value" => value })
  end

  @doc """
    Retrieve the list of Collections accessible by the authenticated API key
    that meet the search criteria.

    https://m2x.att.com/developer/documentation/v2/collections#List-collections
  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["collections"], fn (attrs) ->
          %M2X.Collection { client: client, attrs: attrs }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Add device to specified Collection.

    https://m2x.att.com/developer/documentation/v2/collections#Add-device-to-collection
  """
  def add_device(coll = %M2X.Collection { client: client }, device_id, params) do
    M2X.Client.put(client, path(coll)<>"/devices/"<>device_id, params)
  end

  @doc """
    Remove device from secified Collection.

    https://m2x.att.com/developer/documentation/v2/collections#Remove-device-from-collection
  """
  def remove_device(coll = %M2X.Collection { client: client }, device_id, params) do
    M2X.Client.delete(client, path(coll)<>"/devices/"<>device_id, params)
  end

end
