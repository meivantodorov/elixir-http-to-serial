# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

use Mix.Config

config :maru, HttpToSerial, http: [port: 8800, ip: {0, 0, 0, 0}]

config :http_to_serial,
  port: "ttyO4",
  speed: 115_200,
  wait_for_device_response: 200,
  timer_msg_handler: 2000,
  timer_net_status: 1000,
  timer_maintenance: 3000,
  reconnect_time: 2000,
  ws_host: "ws://192.168.0.104:4000/socket/websocket",
  ws_topic: "status: publish"
