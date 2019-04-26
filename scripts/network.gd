extends Node

const HOST_URL: String = "http://localhost:9000/"
const LOGIN_URL: String = HOST_URL + "authorization-service/oauth/token"


var tmp: HTTPClient = HTTPClient.new()

var token: String = ""

func query(data) -> String:
	return ""