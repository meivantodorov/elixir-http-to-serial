defmodule HttpToSerial do
  use Maru.Router
  plug(Plug.Logger)

  post do
    raw_request =
      read_body(conn)
      |> elem(1)

    req =
      try do
        Serialization.deserialize(raw_request)
      rescue
        e ->
          build_response(:error, "Failed to deserialize request", "Bad request")
      end
    process(conn, req)
  end

  defp process(conn, req) do
        resp = Serial.request(req)
        resp = build_response(:ok, "", resp)
        json(conn, resp)
  end

  defp build_response(status, err_reason, message) do
      %{status: status,
        error: err_reason,
        message: message} |> Serialization.serialize
  end
end
