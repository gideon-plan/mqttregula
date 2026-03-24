{.experimental: "strict_funcs".}
import std/[unittest, tables]
import mqttregula
suite "topic_map":
  test "resolve known topic":
    var r = new_router()
    r.add_mapping("sensor/temperature", "temperature")
    check r.resolve("sensor/temperature/room1") == "temperature"
  test "resolve unknown topic":
    let r = new_router("default")
    check r.resolve("unknown/topic") == "default"
suite "ingest":
  test "parse kv payload":
    let fields = parse_kv_payload("temp=25\nunit=C")
    check fields["temp"] == "25"
  test "ingest message":
    var r = new_router()
    r.add_mapping("sensor", "sensor_event")
    var inserted_type = ""
    let mock_insert: InsertFn = proc(ft: string, f: Table[string, string]): Result[void, BridgeError] {.raises: [].} =
      inserted_type = ft; Result[void, BridgeError](ok: true)
    let msg = MqttMessage(topic: "sensor/temp", payload: "v=1")
    discard ingest_message(msg, r, mock_insert)
    check inserted_type == "sensor_event"
suite "session":
  test "process message":
    var r = new_router()
    let mock_insert: InsertFn = proc(ft: string, f: Table[string, string]): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    var s = new_session(r, mock_insert, proc(): int = 1)
    let result = s.process(MqttMessage(topic: "t", payload: "k=v"))
    check result.is_good
    check s.messages_ingested == 1
