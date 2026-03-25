## session.nim -- Combined MQTT + regula session.
{.experimental: "strict_funcs".}

import basis/code/choice, topic_map, ingest
type
  MqttRegulaSession* = object
    router*: TopicRouter
    insert_fn*: InsertFn
    fire_fn*: proc(): int {.raises: [].}
    messages_ingested*: int
proc new_session*(router: TopicRouter, insert_fn: InsertFn,
                  fire_fn: proc(): int {.raises: [].}): MqttRegulaSession =
  MqttRegulaSession(router: router, insert_fn: insert_fn, fire_fn: fire_fn)
proc process*(s: var MqttRegulaSession, msg: MqttMessage): Choice[int] =
  let r = ingest_message(msg, s.router, s.insert_fn)
  if r.is_bad: return bad[int](r.err)
  inc s.messages_ingested
  good(s.fire_fn())
