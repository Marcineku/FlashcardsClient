extends Node

onready var HelloLabel: Label = $GUI/HelloLabel
onready var CategoryContainer: VBoxContainer = $GUI/ScrollContainer/VBoxContainer

var category = preload("res://scenes/category.tscn")

func _ready():	
	network.connect("user_data_request_ok", self, "_on_user_data_request_ok")
	network.connect("get_categories_request_ok", self, "_on_get_categories_request_ok")
	
	network.get_categories()

func _on_user_data_request_ok(response: Dictionary):
	HelloLabel.text = "Hello " + network.user_full_name + "!"

func _on_get_categories_request_ok(response: Array):
	for item in response:
		var new_category = category.instance()
		new_category.init(item)
		CategoryContainer.add_child(new_category)

func _on_LogoutButton_pressed():
	network.logout()
