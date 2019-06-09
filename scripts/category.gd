extends Control

onready var NameLabel: Label = $VBoxContainer/NameLabel
onready var DifficultyProgressBar: ProgressBar = $VBoxContainer/DifficultyLevel
onready var DifficultyLabel: Label = $VBoxContainer/DifficultyLevel/Label

var _category_id: int = 0
var _is_category: bool = true
var _name: String = "Name"
var _description: String = "Description"
var _difficulty: int = 0
var _public: bool = false

func _ready():
	NameLabel.text = _name
	DifficultyProgressBar.value = _difficulty
	DifficultyLabel.text = String(_difficulty) + "/10"

func init(data: Dictionary, is_category: bool):
	_category_id = data["categoryId"]
	_name = data["name"]
	_description = data["description"]
	_difficulty = data["difficulty"]
	_public = data["public"]
	_is_category = is_category

func _on_Button_pressed():
	if _is_category:
		network.join_category(_category_id)
	else:
		network.choose_collection(self)
