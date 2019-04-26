extends Node

onready var UsernameLine: LineEdit = $GUI/VBoxContainer/UsernameLine
onready var PasswordLine: LineEdit = $GUI/VBoxContainer/PasswordLine
onready var LoginButton: Button = $GUI/VBoxContainer/LoginButton
onready var LoginInfo: Label = $GUI/LoginInfo
onready var LoginRequest: HTTPRequest = $GUI/VBoxContainer/LoginRequest

func _on_LoginButton_pressed():
	LoginButton.disabled = true
	var headers: PoolStringArray = [
		"Authorization: " + "Basic " + Marshalls.utf8_to_base64("browser:"),
		"Content-Type: application/x-www-form-urlencoded"
	]
	var body: Dictionary = {
		"scope": "ui",
		"username": UsernameLine.text,
		"password": PasswordLine.text,
		"grant_type": "password"
	}
	LoginRequest.request(network.LOGIN_URL, headers, false, HTTPClient.METHOD_POST, tmp.query_string_from_dict(body))

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray):
	LoginButton.disabled = false
	
	var parseResult: JSONParseResult = JSON.parse(body.get_string_from_utf8())
	if parseResult.error != OK || typeof(parseResult.result) != TYPE_DICTIONARY:
		LoginInfo.text = "Invalid JSON response"
	var response: Dictionary = parseResult.result
	
	if response_code == 400:
		LoginInfo.text = response["error_description"];
	
	print(response)