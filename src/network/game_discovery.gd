extends Node
class_name GameDiscovery


var firebase_auth_url
var firestore_url
var id_token
var ip

signal authenticated
signal game_registered
signal games_refreshed(games: Array)
signal error(message: String)

func register_game(game_name: String):
	if id_token == null:
		authenticate_anonymously()
		await authenticated
	var err = await _upnp_setup()
	if err != OK:
		emit_signal("error", "Failed to setup UPNP: No valid gateway found")
		push_error("Failed to setup UPNP: No valid gateway found")
		return
	var game_info = GameInfo.new(game_name, ip)
	_register_game_to_firestore(game_info)
	Networking.host()

func obtain_games():
	if id_token == null:
		authenticate_anonymously()
		await authenticated
	_obtain_game_list()

func join_game(game_info: GameInfo):
	Networking.join(game_info.ip)
	print("Joining game: ", game_info.name, " at ", game_info.ip)

func _init():
	_load_config()

func _load_config():
	var config = ConfigFile.new()
	var err = config.load("secrets.cfg")
	if err == ERR_FILE_NOT_FOUND:
		emit_signal("error", "secrets.cfg not found, creating a new one")
		push_error("secrets.cfg not found, creating a new one")
		config.set_value("Firebase","PROJECT_ID","TODO_PROJECT_ID")
		config.set_value("Firebase","API_KEY","TODO_API_KEY")
		config.save("secrets.cfg")
		return
	if err != OK:
		emit_signal("error", "Error loading secrets.cfg")
		push_error("Error loading secrets.cfg")
		return
	var firebase_project_id = config.get_value("Firebase","PROJECT_ID")
	var firebase_api_key = config.get_value("Firebase","API_KEY")
	firebase_auth_url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + firebase_api_key
	firestore_url = "https://firestore.googleapis.com/v1/projects/" + firebase_project_id + "/databases/(default)/documents/games"

func authenticate_anonymously():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_authentication_completed)

	http_request.request(
		firebase_auth_url,
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify({"returnSecureToken": true}))

func _on_authentication_completed(_result, response_code, _headers, body):
	if response_code != 200:
		emit_signal("error", "Failed to authenticate: " + str(response_code))
		push_error("Failed to authenticate: ", response_code)
		return

	var response = _parse_json(body.get_string_from_utf8())
	if response.has("idToken"):
		id_token = response["idToken"]
		emit_signal("authenticated")

func _register_game_to_firestore(game_info: GameInfo):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_game_registered)
	http_request.request(
		firestore_url, 
		["Content-Type: application/json","Authorization: Bearer " + id_token],
		HTTPClient.METHOD_POST, 
		game_info.to_doc())

func _on_game_registered(_result, response_code, _headers, body):
	if response_code != 200:
		emit_signal("error", "Failed to interact with Firestore: " + str(response_code))
		push_error("Failed to interact with Firestore: ", response_code, body.get_string_from_utf8())
		return
	emit_signal("game_registered")

func _parse_json(json_text):
	var json = JSON.new()
	var err = json.parse(json_text)
	if err != OK:
		emit_signal("error", "Error parsing JSON" + str(err))
		push_error("Error parsing JSON")
		return {}
	return json.data

func _obtain_game_list():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(
		firestore_url, 
		["Content-Type: application/json","Authorization: Bearer " + id_token],
		HTTPClient.METHOD_GET)
	http_request.request_completed.connect(_on_http_request_request_completed)

func _on_http_request_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		emit_signal("error", "Failed to interact with Firestore: " + str(response_code))
		push_error("Failed to interact with Firestore: ", response_code, body.get_string_from_utf8())
		return
	var response = _parse_json(body.get_string_from_utf8())
	var games: Array[GameInfo] = []
	for game in response["documents"]:
		games.append(GameInfo.from_doc(game))
	emit_signal("games_refreshed", games)

func _upnp_setup() -> int:
	var thread = Thread.new()
	thread.start(_upnp_setup_thread.bind(Networking.PORT))
	var upnp = await thread.wait_to_finish()
	if upnp == null:
		return ERR_CONNECTION_ERROR
	ip = upnp.query_external_address()
	return OK

func _upnp_setup_thread(port) -> UPNP:
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		return

	if !upnp.get_gateway() or !upnp.get_gateway().is_valid_gateway():
		push_error("No valid gateway found")
		return
	upnp.add_port_mapping(port)
	ip = upnp.query_external_address()
	return upnp
