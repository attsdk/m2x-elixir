defmodule M2X.Device do
  @moduledoc """
    Wrapper for the AT&T M2X Device API.
    https://m2x.att.com/developer/documentation/v2/device
  """
  use M2X.Resource, path: {"/devices", :id}

  @doc """
    Retrieve a view of the Device associated with the given unique id.

    https://m2x.att.com/developer/documentation/v2/device#View-Device-Details
  """
  def fetch(client = %M2X.Client{}, id) do
    case M2X.Client.get(client, path(id)) do
      {:ok, res} -> {:ok, %M2X.Device { client: client, attributes: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Retrieve the list of Devices accessible by the authenticated API key.

    https://m2x.att.com/developer/documentation/v2/device#List-Devices
  """
  def list(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path, params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attributes) ->
          %M2X.Device { client: client, attributes: attributes }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Retrieve the list of Devices accessible by the authenticated API key that
    meet the search criteria.

    https://m2x.att.com/developer/documentation/v2/device#Search-Devices
  """
  def search(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path<>"/search", params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attributes) ->
          %M2X.Device { client: client, attributes: attributes }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Search the catalog of public Devices.

    This allows unauthenticated users to search Devices from other users
    that have been marked as public, allowing them to read public Device
    metadata, locations, streams list, and view each Devices' stream metadata
    and its values.

    https://m2x.att.com/developer/documentation/v2/device#List-Search-Public-Devices-Catalog
  """
  def catalog(client = %M2X.Client{}, params\\nil) do
    case M2X.Client.get(client, @main_path<>"/catalog", params) do
      {:ok, res} ->
        list = Enum.map res.json["devices"], fn (attributes) ->
          %M2X.Device { client: client, attributes: attributes }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Get location details of an existing Device.

    Note that this method can return an empty value (response status
    of 204) if the device has no location defined.

    https://m2x.att.com/developer/documentation/v2/device#Read-Device-Location
  """
  def get_location(device = %M2X.Device { client: client }) do
    M2X.Client.get(client, path(device)<>"/location")
  end

  @doc """
    Get location history details of an existing Device.

    https://m2x.att.com/developer/documentation/v2/device#Read-Device-Location-History
  """
  def location_history(device = %M2X.Device { client: client }, params\\%{}) do
    M2X.Client.get(client, path(device)<>"/location/waypoints", params)
  end

  @doc """
    Update the current location of the specified device.

    https://m2x.att.com/developer/documentation/v2/device#Update-Device-Location
  """
  def update_location(device = %M2X.Device { client: client }, params) do
    M2X.Client.put(client, path(device)<>"/location", params)
  end

  @doc """
    Get the custom metadata for the specified Device.

    https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata
  """
  def metadata(device = %M2X.Device { client: client }) do
    M2X.Client.get(client, path(device)<>"/metadata")
  end

  @doc """
    Update the custom metadata for the specified Device.

    https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata
  """
  def update_metadata(device = %M2X.Device { client: client }, params) do
    M2X.Client.put(client, path(device)<>"/metadata", params)
  end

  @doc """
    Get the custom metadata for the specified Device.

    https://m2x.att.com/developer/documentation/v2/device#Read-Device-Metadata-Field
  """
  def get_metadata_field(device = %M2X.Device { client: client }, name) do
    M2X.Client.get(client, path(device)<>"/metadata/"<>name)
  end

  @doc """
    Update the custom metadata for the specified Device.

    https://m2x.att.com/developer/documentation/v2/device#Update-Device-Metadata-Field
  """
  def set_metadata_field(device = %M2X.Device { client: client }, name, value) do
    M2X.Client.put(client, path(device)<>"/metadata/"<>name, %{ "value" => value })
  end

  @doc """
    List values from all data streams of a Device.

    https://m2x.att.com/developer/documentation/v2/device#List-Values-from-all-Data-Streams-of-a-Device
  """
  def values(device = %M2X.Device { client: client }, params) do
    M2X.Client.get(client, path(device)<>"/values", params)
  end

  @doc """
    Search values from all data streams of a Device.

    https://m2x.att.com/developer/documentation/v2/device#Search-Values-from-all-Data-Streams-of-a-Device
  """
  def values_search(device = %M2X.Device { client: client }, params) do
    M2X.Client.get(client, path(device)<>"/values/search", params)
  end

  @doc """
    Export values from all data streams of a Device.

    https://m2x.att.com/developer/documentation/v2/device#Export-Values-from-all-Data-Streams-of-a-Device
  """
  def values_export_csv(device = %M2X.Device { client: client }, params\\%{}) do
    M2X.Client.get(client, path(device)<>"/values/export.csv", params)
  end

  @doc """
    Post Device Update (Single Values to Multiple Streams)

    This method allows posting single values to multiple streams.

    https://m2x.att.com/developer/documentation/v2/device#Post-Device-Update--Single-Values-to-Multiple-Streams-
  """
  def post_update(device = %M2X.Device { client: client }, params) do
    M2X.Client.post(client, path(device)<>"/update", params)
  end

  @doc """
    Post Device Updates (Multiple Values to Multiple Streams)

    This method allows posting multiple values to multiple streams
    belonging to a device and optionally, the device location.

    https://m2x.att.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams-
  """
  def post_updates(device = %M2X.Device { client: client }, params) do
    M2X.Client.post(client, path(device)<>"/updates", params)
  end

  @doc """
    Retrieve list of Streams associated with the specified Device.

    https://m2x.att.com/developer/documentation/v2/device#List-Data-Streams
  """
  def streams(device = %M2X.Device { client: client }) do
    case M2X.Client.get(client, path(device)<>"/streams") do
      {:ok, res} ->
        list = Enum.map res.json["streams"], fn (attributes) ->
          %M2X.Stream { client: client, attributes: attributes, under: path(device) }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Get details of a specific Stream associated with the Device.

    https://m2x.att.com/developer/documentation/v2/device#View-Data-Stream
  """
  def stream(device = %M2X.Device { client: client }, name) do
    M2X.Stream.refreshed %M2X.Stream {
      client: client, under: path(device), attributes: %{ "name"=>name }
    }
  end

  @doc """
    Update a Stream associated with the Device with the given parameters.
    If a Stream with this name does not exist it will be created.

    https://m2x.att.com/developer/documentation/v2/device#Create-Update-Data-Stream
  """
  def update_stream(device = %M2X.Device { client: client }, name, params) do
    M2X.Stream.update! %M2X.Stream {
      client: client, under: path(device), attributes: %{ "name"=>name }
    }, params
  end
  def create_stream(a,b,c) do update_stream(a,b,c) end # Alias

  @doc """
    Retrieve the list of recent commands sent to the Device.

    https://m2x.att.com/developer/documentation/v2/commands#Device-s-List-of-Received-Commands
  """
  def commands(device = %M2X.Device { client: client }) do
    case M2X.Client.get(client, path(device)<>"/commands") do
      {:ok, res} ->
        list = Enum.map res.json["commands"], fn (attributes) ->
          %M2X.Command { client: client, attributes: attributes }
        end
        {:ok, list}
      error_pair -> error_pair
    end
  end

  @doc """
    Get details of a received command for this Device.

    https://m2x.att.com/developer/documentation/v2/commands#Device-s-View-of-Command-Details
  """
  def command(device = %M2X.Device { client: client }, command_id) do
    case M2X.Client.get(client, path(device)<>"/commands/"<>command_id) do
      {:ok, res} -> {:ok, %M2X.Command { client: client, attributes: res.json }}
      error_pair -> error_pair
    end
  end

  @doc """
    Mark the given command as processed by this Device.

    https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Processed
  """
  def process_command(device = %M2X.Device { client: client },
                      %M2X.Command { attributes: %{ "id" => command_id } },
                      params\\%{}) do
    req_path = path(device)<>"/commands/"<>command_id<>"/process"
    M2X.Client.post(client, req_path, params)
  end

  @doc """
    Mark the given command as rejected by this Device.

    https://m2x.att.com/developer/documentation/v2/commands#Device-Marks-a-Command-as-Rejected
  """
  def reject_command(device = %M2X.Device { client: client },
                     %M2X.Command { attributes: %{ "id" => command_id } },
                     params\\%{}) do
    req_path = path(device)<>"/commands/"<>command_id<>"/reject"
    M2X.Client.post(client, req_path, params)
  end

end
