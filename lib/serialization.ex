defmodule Serialization do
  @moduledoc """
  Documentation for the serialization componnet

  ## TODO:
  - examples
  - better documentation
  """

  @type data :: map() | binary()

  @type deserialized_resp() :: map()
  @type serialized_resp() :: binary()

  @spec serialize(data()) :: serialized_resp()
  def serialize(data),
    do:
  data
  |> Msgpax.pack!(iodata: false)
  |> Base.encode64()

  @spec deserialize(data()) :: deserialized_resp()
  def deserialize(data),
    do:
  data
  ##|> Poison.decode!()
  |> Base.decode64!()
  |> Msgpax.unpack!()
end
