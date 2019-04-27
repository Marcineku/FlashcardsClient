extends Node

onready var HelloLabel: Label = $HelloLabel

func _ready():
	network.connect("user_data_request_ok", self, "_on_user_data_request_ok")

func _on_user_data_request_ok(response: Dictionary):
	HelloLabel.text = "Hello " + network.user_full_name + "!"

func _on_LogoutButton_pressed():
	network.logout()