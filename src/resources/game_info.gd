extends Resource
class_name GameInfo

@export var name: String = "Game Name"
@export var ip: String = "127.0.0.1"

func _init(game_name: String, game_ip: String):
    self.name = game_name
    self.ip = game_ip

func to_doc() -> String:
    return JSON.stringify({
        "fields": {
            "ip": {
                "stringValue": self.ip
            },
            "name": {
                "stringValue": self.name
            },
        }
    })

static func from_doc(doc) -> GameInfo:
    return GameInfo.new(
        doc["fields"]["name"]["stringValue"],
		doc["fields"]["ip"]["stringValue"]
    )