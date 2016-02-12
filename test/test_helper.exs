
defmodule MockEngine do
  use GenServer

  defmodule State do
    defstruct \
      ref:         nil,
      api_key:     nil,
      api_base:    nil,
      req_verb:    nil,
      req_path:    nil,
      req_body:    nil,
      res_status:  nil,
      res_body:    nil,
      res_headers: nil
  end

  def start do
    GenServer.start_link(MockEngine, %State{}, name: MockEngineProcess)
  end

  def client(request, response) do
    client = %M2X.Client {
      api_key: "0123456789abcdef0123456789abcdef",
      http_engine: MockEngine,
    }
    setup(client, request, response)
    client
  end

  def setup(client, request, response) do
    start
    GenServer.call MockEngineProcess, {:setup, client, request, response}
  end

  def request(verb, url, header_list, body, _) do
    GenServer.call MockEngineProcess, {:request, verb, url, header_list, body}
  end

  def body(ref) do
    GenServer.call MockEngineProcess, {:body, ref}
  end

  defp to_json(nil) do "" end
  defp to_json(params) do
    {:ok, json} = JSON.encode(params)
    json
  end

  def handle_call(
    {:setup, client, {req_verb, req_path, req_params},
                     {res_status, res_params, res_headers}}, _, state
  ) do
    client = client || state.client
    res_headers = Map.to_list(res_headers || %{})
    if res_params do
      res_headers = [{"Content-Type", "application/json; charset=UTF-8"}] ++ res_headers
    end

    {:reply, :ok, %State {
      ref:         make_ref,
      api_key:     client && client.api_key  || state.api_key,
      api_base:    client && client.api_base || state.api_base,
      req_verb:    req_verb,
      req_path:    req_path,
      req_body:    to_json(req_params),
      res_status:  res_status,
      res_body:    to_json(res_params),
      res_headers: res_headers
    }}
  end

  def handle_call({:request, verb, url, header_list, body}, _, state) do
    headers = Enum.into(header_list, %{})
    {^verb, ^url} = {state.req_verb, state.api_base <> state.req_path}
    case state.req_body do
    "" -> ^body = ""
    _  ->
      {:ok, "application/json"} = Map.fetch(headers, "Content-Type")
      ^body = state.req_body
    end
    api_key = state.api_key
    user_agent = M2X.Client.user_agent
    {:ok, ^api_key}    = Map.fetch(headers, "X-M2X-KEY")
    {:ok, ^user_agent} = Map.fetch(headers, "User-Agent")
    {:reply, {:ok, state.res_status, state.res_headers, state.ref}, state}
  end

  def handle_call({:body, given_ref}, _, state) do
    ^given_ref = state.ref
    {:reply, {:ok, state.res_body}, state}
  end
end


ExUnit.start()
