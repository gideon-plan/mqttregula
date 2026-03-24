## action.nim -- Regula rule actions publishing MQTT messages.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import lattice
type
  MqttPublishFn* = proc(topic, payload: string): Result[void, BridgeError] {.raises: [].}
proc publish_alert*(pub_fn: MqttPublishFn, alert_topic: string,
                    fields: Table[string, string]): Result[void, BridgeError] =
  var lines: seq[string]
  for k, v in fields: lines.add(k & "=" & v)
  pub_fn(alert_topic, lines.join("\n"))
