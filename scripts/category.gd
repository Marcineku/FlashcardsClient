extends Control

onready var NameLabel: Label = $VBoxContainer/NameLabel
onready var DifficultyProgressBar: ProgressBar = $VBoxContainer/DifficultyLevel
onready var DifficultyLabel: Label = $VBoxContainer/DifficultyLevel/Label
onready var JoinButton: Button = $VBoxContainer/JoinButton
onready var EditButton: Button = $VBoxContainer/Button
onready var PlayButton: Button = $VBoxContainer/PlayButton

var _category_id: int = 0
var _collection_id: int = 0
var _learning_progress: int = 0
var _modifiable: bool = false
var _is_category: bool = true
var _name: String = "Name"
var _description: String = "Description"
var _difficulty: int = 0
var _public: bool = false

func _ready():
	NameLabel.text = _name
	DifficultyProgressBar.value = _difficulty
	DifficultyLabel.text = String(_difficulty) + "/10"
	
	if _is_category:
		JoinButton.visible = true
		EditButton.visible = false
		PlayButton.visible = false
	else:
		JoinButton.visible = false
		EditButton.visible = true
		PlayButton.visible = true

func init(data: Dictionary, is_category: bool):
	_category_id = data["categoryId"]
	_name = data["name"]
	_description = data["description"]
	_difficulty = data["difficulty"]
	_public = data["public"]
	_is_category = is_category

func init_collection(data: Dictionary):
	_collection_id = data["collectionId"]
	_learning_progress = data["learningProgress"]
	_modifiable = data["modifiable"]

func _on_Button_pressed():
	if _is_category:
		network.join_category(_category_id)
	else:
		network.choose_collection(self)

func _on_PlayButton_pressed():
	if !_is_category:
		network.play_collection(self)

func _on_JoinButton_pressed():
	if _is_category:
		network.join_category(_category_id)
	else:
		network.choose_collection(self)
