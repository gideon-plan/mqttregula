## topic_map.nim -- MQTT topic -> regula fact type mapping.
{.experimental: "strict_funcs".}
import std/strutils
type
  TopicMapping* = object
    topic_pattern*: string
    fact_type*: string
  TopicRouter* = object
    mappings*: seq[TopicMapping]
    default_fact_type*: string
proc new_router*(default_type: string = "mqtt_event"): TopicRouter =
  TopicRouter(default_fact_type: default_type)
proc add_mapping*(r: var TopicRouter, pattern, fact_type: string) =
  r.mappings.add(TopicMapping(topic_pattern: pattern, fact_type: fact_type))
proc resolve*(r: TopicRouter, topic: string): string =
  for m in r.mappings:
    if topic.startsWith(m.topic_pattern): return m.fact_type
  r.default_fact_type
