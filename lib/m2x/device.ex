defmodule M2X.Device do
  use M2X.Resource, main_path: "/devices"

  def path(%M2X.Device { attributes: %{ "id"=>id } }) do path(id) end
  def path(id) when is_binary(id) do @main_path<>"/"<>id end

  ##
  # Module functions

  # Retrieve a view of the Device associated with the given unique id.
  #
  # https://m2x.att.com/developer/documentation/v2/device#List-Search-Devices
  def fetch(client, id) do
    res = M2X.Client.get(client, path(id))
    res.success? and %M2X.Device { client: client, attributes: res.json }
  end

  # Retrieve the list of Devices accessible by the authenticated API key that
  # meet the search criteria.
  #
  # https://m2x.att.com/developer/documentation/v2/device#List-Search-Devices
  def list(client, params\\nil) do
    res = M2X.Client.get(client, @main_path, params)
    res.success? and Enum.map res.json["devices"], fn (attributes) ->
      %M2X.Device { client: client, attributes: attributes }
    end
  end

  # Search the catalog of public Devices.
  #
  # This allows unauthenticated users to search Devices from other users
  # that have been marked as public, allowing them to read public Device
  # metadata, locations, streams list, and view each Devices' stream metadata
  # and its values.
  #
  # https://m2x.att.com/developer/documentation/v2/device#List-Search-Public-Devices-Catalog
  def catalog(client, params\\nil) do
    res = M2X.Client.get(client, @main_path<>"/catalog", params)
    res.success? and Enum.map res.json["devices"], fn (attributes) ->
      %M2X.Device { client: client, attributes: attributes }
    end
  end

  ##
  # Struct functions

  # Get location details of an existing Device.
  #
  # Note that this method can return an empty value (response status
  # of 204) if the device has no location defined.
  #
  # https://m2x.att.com/developer/documentation/v2/device#Read-Device-Location
  def get_location(device) do
    M2X.Client.get(device.client, path(device)<>"/location")
  end

  # Update the current location of the specified device.
  #
  # https://m2x.att.com/developer/documentation/v2/device#Update-Device-Location
  def update_location(device, params) do
    M2X.Client.put(device.client, path(device)<>"/location", params)
  end

  # Post Device Updates (Multiple Values to Multiple Streams)
  #
  # This method allows posting multiple values to multiple streams
  # belonging to a device and optionally, the device location.
  #
  # https://staging.m2x.sl.attcompute.com/developer/documentation/v2/device#Post-Device-Updates--Multiple-Values-to-Multiple-Streams-
  def post_updates(device, params) do
    M2X.Client.post(device.client, path(device)<>"/updates", params)
  end

end
