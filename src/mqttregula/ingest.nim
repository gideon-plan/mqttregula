## ingest.nim -- MQTT subscription loop, parse payload, insert WME.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import basis/code/choice, topic_map
type
  MqttMessage* = object
    topic*: string
    payload*: string
  InsertFn* = proc(fact_type: string, fields: Table[string, string]): Choice[bool] {.raises: [].}
proc parse_kv_payload*(payload: string): Table[string, string] =
  for line in payload.splitLines():
    let eq = line.find('=')
    if eq > 0: result[line[0 ..< eq].strip()] = line[eq+1 ..< line.len].strip()
proc ingest_message*(msg: MqttMessage, router: TopicRouter,
                     insert_fn: InsertFn): Choice[bool] =
  let fact_type = router.resolve(msg.topic)
  var fields = parse_kv_payload(msg.payload)
  fields["_topic"] = msg.topic
  insert_fn(fact_type, fields)
