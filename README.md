# Simple http to serial node written in Elixir

## OS
Linux

## Installation

`mix deps.get`

## Run

`iex -S mix`

## Required
`Msgpack serialization`

## Make release

### create `rel` folder and the config file:
`mix release.init`

### create prod release:
`MIX_ENV=prod mix release`

### More details:
https://hackernoon.com/mastering-elixir-releases-with-distillery-a-pretty-complete-guide-497546f298bc


## Run tests
`mix test`

### Request

```
Sending post to with encoded with Base64 Msgpack binaries

Post -> Raw_binary -> Msgpack.pack -> Base64.encode
```
