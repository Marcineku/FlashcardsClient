extends Node

class Collection:
	var _category_id: int = -1
	var _is_category: bool = true
	var _name: String = "Name"
	var _description: String = "Description"
	var _difficulty: int = 0
	var _public: bool = false

onready var HelloLabel: Label = $GUI/HelloLabel
onready var Tabs: TabContainer = $GUI/TabContainer
onready var CategoryContainer: VBoxContainer = $GUI/TabContainer/Categories/ScrollContainer/GridContainer
onready var CategoryName: LineEdit = $"GUI/TabContainer/Add category/LineEdit"
onready var CategoryDescription: TextEdit = $"GUI/TabContainer/Add category/TextEdit"
onready var CategoryDifficulty: SpinBox = $"GUI/TabContainer/Add category/SpinBox"
onready var CollectionsContainer: VBoxContainer = $GUI/TabContainer/Collections/ScrollContainer/VBoxContainer
onready var CollectionName: LineEdit = $"GUI/TabContainer/Edit collection/EditCollection/LineEdit"
onready var CollectionDescription: TextEdit = $"GUI/TabContainer/Edit collection/EditCollection/TextEdit"
onready var CollectionIsPublic: CheckBox = $"GUI/TabContainer/Edit collection/EditCollection/CheckBox"
onready var WordPLTranslation: TextEdit = $"GUI/TabContainer/Edit collection/AddWord/TextEdit"
onready var WordENGTranslation: TextEdit = $"GUI/TabContainer/Edit collection/AddWord/TextEdit2"
onready var WordExamples: TextEdit = $"GUI/TabContainer/Edit collection/AddWord/TextEdit3"
onready var WordDifficulty: SpinBox = $"GUI/TabContainer/Edit collection/AddWord/SpinBox"
onready var WordsContainer: VBoxContainer = $"GUI/TabContainer/Edit collection/Words/VBoxContainer"
onready var ExamplesContainer: VBoxContainer = $"GUI/TabContainer/Edit collection/Examples/VBoxContainer"

var category = preload("res://scenes/category.tscn")
var word = preload("res://scenes/word.tscn")
var empty = preload("res://scenes/empty.tscn")
var word_example = preload("res://scenes/example.tscn")

var chosen_collection: Collection = Collection.new()

func _ready():
	network.connect("user_data_request_ok", self, "_on_user_data_request_ok")
	network.connect("get_categories_request_ok", self, "_on_get_categories_request_ok")
	network.connect("create_new_category_request_ok", self, "_on_create_new_category_request_ok")
	network.connect("get_collections_request_ok", self, "_on_get_collections_request_ok")
	network.connect("join_category_request_ok", self, "_on_join_category_request_ok")
	network.connect("choose_collection", self, "_on_choose_collection")
	network.connect("get_words_request_ok", self, "_on_get_words_request_ok")
	network.connect("choose_word", self, "_on_choose_word")
	
	network.get_categories()

func _copy_collection(category):
	chosen_collection._category_id = category._category_id - 1
	chosen_collection._is_category = category._is_category
	chosen_collection._name = category._name
	chosen_collection._description = category._description
	chosen_collection._difficulty = category._difficulty
	chosen_collection._public = category._public

func _on_user_data_request_ok(response: Dictionary):
	HelloLabel.text = "Hello " + network.user_full_name + "!"

func _on_get_categories_request_ok(response: Array):
	for child in CategoryContainer.get_children():
		child.queue_free()
	for item in response:
		var new_category = category.instance()
		new_category.init(item, true)
		CategoryContainer.add_child(new_category)
	
	for i in range(4):
		CategoryContainer.add_child(empty.instance())

func _on_create_new_category_request_ok(response):
	print(response)

func _on_get_collections_request_ok(response):
	for child in CollectionsContainer.get_children():
		child.queue_free()
	for item in response:
		var new_collection = category.instance()
		new_collection.init(item.category, false)
		CollectionsContainer.add_child(new_collection)
	
	for i in range(4):
		CollectionsContainer.add_child(empty.instance())

func _on_join_category_request_ok(response):
	network.get_categories()

func _on_get_words_request_ok(response):
	for child in WordsContainer.get_children():
		child.queue_free()
	for item in response:
		var new_word = word.instance()
		new_word.init(item)
		WordsContainer.add_child(new_word)
	
	WordsContainer.add_child(empty.instance())

func _on_choose_collection(collection):
	_copy_collection(collection)
	CollectionName.text = chosen_collection._name
	CollectionDescription.text = chosen_collection._description
	CollectionIsPublic.pressed = chosen_collection._public
	network.get_words(chosen_collection._category_id)
	Tabs.current_tab = 3

func _on_choose_word(word):
	for child in ExamplesContainer.get_children():
		child.queue_free()
	for item in word._engExamples:
		var new_example = word_example.instance()
		new_example.init(item)
		ExamplesContainer.add_child(new_example)

func _on_LogoutButton_pressed():
	network.logout()

func _on_SubmitNewCategoryButton_pressed():
	network.create_new_category(CategoryName.text, CategoryDescription.text, CategoryDifficulty.get_line_edit().text)

func _on_TabContainer_tab_selected(tab: int):
	match tab:
		0:
			network.get_categories()
		2:
			network.get_collections()
		3:
			if chosen_collection != null:
				CollectionName.text = chosen_collection._name
				CollectionDescription.text = chosen_collection._description
				CollectionIsPublic.pressed = chosen_collection._public

func _on_EditCollectionButton_pressed():
	network.update_collection(chosen_collection._category_id, CollectionName.text, CollectionDescription.text, CollectionIsPublic.pressed)

func _on_NewWordButton_pressed():
	network.create_new_word(chosen_collection._category_id, WordPLTranslation.text, WordENGTranslation.text, WordDifficulty.get_line_edit().text, WordExamples.text)
