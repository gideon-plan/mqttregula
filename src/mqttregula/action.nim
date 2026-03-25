## action.nim -- Regula rule actions publishing MQTT messages.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import basis/code/choice
type
  MqttPublishFn* = proc(topic, payload: string): Choice[bool] {.raises: [].}
proc publish_alert*(pub_fn: MqttPublishFn, alert_topic: string,
                    fields: Table[string, string]): Choice[bool] =
  var lines: seq[string]
  for k, v in fields: lines.add(k & "=" & v)
  pub_fn(alert_topic, lines.join("\n"))
