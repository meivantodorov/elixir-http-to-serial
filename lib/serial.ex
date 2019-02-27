defmodule Serial do
  @moduledoc """
  Serial module.
  """

  use GenServer
  require Logger

  @wait_for_device_response Application.get_env(:http_to_serial, :wait_for_device_response)
  @reconnect_time Application.get_env(:http_to_serial, :reconnect_time)

  ## Client API

  @doc """
  Starts the GenServer
  """

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Writes/reads data to/from the UART.

  ##Parameters:
  - msg: Data to write to the UART.

  ##Examples:
  No examples

  """

  @spec request(Binary) :: atom()
  def request(msg) do
    GenServer.call(__MODULE__, {:request, msg}, :infinity)
  end

  @doc """
  Returns the serial module state.

  ##Parameters:
  No parameters

  ##Examples:
  No examples

  """

  @spec get_state() :: map()
  def get_state() do
    GenServer.call(__MODULE__, {:get_state}, :infinity)
  end

  ## Server callbacks

  def init(:ok) do
    {:ok, setup()}
  end

  def handle_call({:request, msg}, _from, %{serial: serial} = state) do
    response =
      try do
        write_to_serial(serial, msg)

      rescue
        _e -> "Failed due to serial communication"
      end
    {:reply, response, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info(
    {:DOWN, pid_ref, :process, _process,
     {:shutdown, {:server_initiated_close, error_code, reason}}},
    %{:conn_ref => conn_ref}
  )
  when pid_ref == conn_ref do
    Logger.error(
      "[Serial] Down, code: #{inspect(error_code)}, reason: #{inspect(reason)}",
      log: :error
    )

    {:noreply, setup()}
  end

  def handle_info(:reconnect, _state) do
    {:noreply, setup()}
  end

  def handle_info(any, state) do
    Logger.error("[Serial] Error for any: #{inspect(any)}", log: :error)
    {:noreply, state}
  end

  ## Internal functions

  def try_reconnecting(), do: Process.send_after(self(), :reconnect, @reconnect_time)

  defp setup() do
    {pid, _serial_status} =
      open_serial(Application.get_env(:http_to_serial, :port), false)

    ref =
    if pid != nil do
      Process.monitor(pid)
    else
      nil
    end

    %{module: self(), serial: pid, start_timestamp: :os.system_time(:seconds), pid_ref: ref}
  end

  defp open_serial(port, active) do
    open_serial(speeds(), port, active)
  end

  defp open_serial([speed | speeds], port, active) do
    # Starts up a UART GenServer.
    {:ok, pid} = Nerves.UART.start_link()

    Logger.info("[Serial] Trying to connect with speed: #{inspect(speed)}...", log: :info)

    # Opens a serial port.
    Nerves.UART.open(pid, port, speed: speed, active: active)
    l = for cmd <- test_requests(), do: write_to_serial(pid, cmd)

    case Enum.any?(
          l,
          fn
            x when x == :error or x == "" -> false
            _ -> true
          end
        ) do
      true ->
        Logger.info("[Serial] Serial connection is successful!", log: :info)
        {pid, :connected}

      false ->
        Nerves.UART.stop(pid)
        open_serial(speeds, port, active)
    end
  end

  defp open_serial([], _, _) do
    Logger.error("[Serial] Cannot connect to serial port! Check serial cable.", log: :error)
    try_reconnecting()
    {nil, :not_connected}
  end

  defp speeds() do
    # [1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200]
    # [324532]
    [115_200]
  end

  defp test_requests() do
    [
    <<1, 37, 90, 80, 65, 5, 48, 49, 49, 53, 3>>,
    <<1, 36, 91, 80, 5, 48, 48, 61, 52, 3>>,
    <<1, 37, 92, 80, 65, 5, 48, 49, 49, 55, 3>>
    ]
  end

  def write_to_serial(serial, msg) when is_pid(serial) do
    # Write data to the opened UART with the default timeout.
    Nerves.UART.write(serial, msg)
    read_response(serial)
  end

  def write_to_serial(_, _) do
    :error
  end

  def read_response(serial) do
    read_response(serial, Nerves.UART.read(serial,@wait_for_device_response),<<>>)
  end

  def read_response(_serial, {:ok, <<>>}, acc) do
    acc
  end

  def read_response(serial, {:ok, <<22>>}, acc) do
    read_response(serial, Nerves.UART.read(serial,@wait_for_device_response), acc)
  end
  def read_response(serial, {:ok, data}, acc) do
    read_response(serial, Nerves.UART.read(serial,@wait_for_device_response), acc <> data)
  end

  def read_response(_, data, _acc) do
    Logger.error("[Serial] Error read: #{inspect(data)}", log: :error)
    :error
  end

end
