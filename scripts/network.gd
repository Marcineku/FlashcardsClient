extends Node

class RequestType:
	const LOGIN: String = "login"
	const USER_DATA: String = "user_data"
	const REGISTER: String = "register"
	const GET_CATEGORIES: String = "get_categories"

const HOST_URL: String = "http://localhost:9000/"
const AUTH_URL: String = "authorization-service/"
const DB_URL: String = "db/linguafranca/"
const LOGIN_URL: String = HOST_URL + AUTH_URL + "oauth/token"
const USER_DATA_URL: String = HOST_URL + AUTH_URL + "users/current"
const REGISTER_URL: String = HOST_URL + DB_URL + "users"
const CATEGORIES_URL: String = HOST_URL + DB_URL + "categories/"

var _http_requests: Dictionary = {
	"login_request": HTTPRequest.new(),
	"user_data_request": HTTPRequest.new(),
	"register_request": HTTPRequest.new(),
	"get_categories_request": HTTPRequest.new(),
	#"create_new_categorie_request": HTTPRequest.new()
}

var _http_client: HTTPClient = HTTPClient.new()

var _token: String = ""

var user_full_name: String = ""
var username: String = ""

signal login_request_ok(response)
signal login_request_error(error_message)
signal user_data_request_ok(response)
signal user_data_request_error(error_message)
signal register_request_ok(response)
signal register_request_error(error_message)
signal get_categories_request_ok(response)
signal get_categories_request_error(error_message)
signal create_new_categorie_request_ok(response)
signal create_new_categorie_request_error(error_message)

func _ready():
	var request_names = _http_requests.keys();
	for request_name in request_names:
		_http_requests[request_name].connect("request_completed", self, "_on_" + request_name + "_completed")
		add_child(_http_requests[request_name])

func _get_response(response_code: int, body: PoolByteArray, request_type: String) -> Dictionary:
	var parseResult: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	
	if parseResult.error != OK:
		emit_signal(request_type + "_request_error", "Invalid JSON response")
		return {}
	var response = parseResult.result
	
	match request_type:
		RequestType.LOGIN:
			if response_code != 200:
				emit_signal(request_type + "_request_error", response["error_description"])
				return {}
		RequestType.REGISTER:
			if response_code != 200:
				emit_signal(request_type + "_request_error", response["message"])
				return {}
		_:
			if response_code != 200:
				emit_signal(request_type + "_request_error", "Error.")
				return {}
	
	emit_signal(request_type + "_request_ok", response)
	return response

func _on_login_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var response: Dictionary = _get_response(response_code, body, RequestType.LOGIN)
	if response.empty():
		return
	
	_token = response["token_type"].capitalize() + " " + response["access_token"]
	
	var user_data_headers: PoolStringArray = [
		"Authorization: " + _token
	]
	_http_requests["user_data_request"].request(USER_DATA_URL, user_data_headers, false, HTTPClient.METHOD_GET)
	
	get_tree().change_scene_to(preload("res://scenes/main_menu.tscn"))

func _on_user_data_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var response: Dictionary = _get_response(response_code, body, RequestType.USER_DATA)
	if response.empty():
		return
	
	user_full_name = response["principal"]["firstName"] + " " + response["principal"]["secondName"]
	username = response["principal"]["username"]
	emit_signal(RequestType.USER_DATA + "_request_ok", response)

func _on_register_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var response: Dictionary = _get_response(response_code, body, RequestType.REGISTER)
	if response.empty():
		return

func _on_get_categories_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	var response: Dictionary = _get_response(response_code, body, RequestType.GET_CATEGORIES)
	if response.empty():
		return

func login(username: String, password: String):
	var headers: PoolStringArray = [
		"Authorization: " + "Basic " + Marshalls.utf8_to_base64("browser:"),
		"Content-Type: application/x-www-form-urlencoded"
	]
	var body: Dictionary = {
		"scope": "ui",
		"username": username,
		"password": password,
		"grant_type": "password"
	}
	_http_requests["login_request"].request(LOGIN_URL, headers, false, HTTPClient.METHOD_POST, _http_client.query_string_from_dict(body))

func logout():
	_token = ""
	user_full_name = ""
	username = ""
	get_tree().change_scene_to(preload("res://scenes/start_menu.tscn"))

func register(email: String, password: String, first_name: String, second_name: String):
	var headers: PoolStringArray = [
		"Content-Type: application/json"
	]
	var body: Dictionary = {
		"email": email,
		"password": password,
		"firstName": first_name,
		"secondName": second_name
	}
	_http_requests["register_request"].request(REGISTER_URL, headers, false, HTTPClient.METHOD_POST, JSON.print(body))

func get_categories():
	var headers: PoolStringArray = [
		"Authorization: " + _token
	]
	_http_requests["get_categories_request"].request(CATEGORIES_URL, headers, false, HTTPClient.METHOD_GET)