extends Node

class Collection:
	var _category_id: int = -1
	var _is_category: bool = true
	var _name: String = "Name"
	var _description: String = "Description"
	var _difficulty: int = 0
	var _public: bool = false
	var _learning_progress: int = 0
	var _modifiable: bool = false

class Word:
	var _word_id: int = -1
	var _eng_trans: String = ""
	var _pl_trans: String = ""

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
onready var PlayViewport: Viewport = $GUI/TabContainer/Play/Viewport
onready var ViewportSprite: Sprite = $GUI/TabContainer/Play/ViewportSprite
onready var Main: Spatial = $GUI/TabContainer/Play/Viewport/Main
onready var Buttons: Control = $GUI/TabContainer/Play/Buttons
onready var Answers: Control = $GUI/TabContainer/Play/Answers

var category = preload("res://scenes/category.tscn")
var word = preload("res://scenes/word.tscn")
var empty = preload("res://scenes/empty.tscn")
var word_example = preload("res://scenes/example.tscn")

var chosen_collection: Collection = Collection.new()
var words: Array
var collection_chosen: bool = false
var is_playing: bool = false

var words_eng: Array = []
var words_pl: Array = []
var words_order: Array = []
var current_word: String = ""
var correct_answer_index: int = 0
var correct_answer: String = ""

func _ready():
	network.connect("user_data_request_ok", self, "_on_user_data_request_ok")
	network.connect("get_categories_request_ok", self, "_on_get_categories_request_ok")
	network.connect("create_new_category_request_ok", self, "_on_create_new_category_request_ok")
	network.connect("get_collections_request_ok", self, "_on_get_collections_request_ok")
	network.connect("join_category_request_ok", self, "_on_join_category_request_ok")
	network.connect("choose_collection", self, "_on_choose_collection")
	network.connect("get_words_request_ok", self, "_on_get_words_request_ok")
	network.connect("choose_word", self, "_on_choose_word")
	network.connect("play_collection", self, "_on_play_collection")
	
	network.get_categories()
	
	PlayViewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	ViewportSprite.texture = PlayViewport.get_texture()
	set_process(true)
	Answers.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_word") && Tabs.current_tab == 4:
		_on_NextButton_pressed()
	if Input.is_action_just_pressed("switch_language") && Tabs.current_tab == 4:
		_on_SwapButton_pressed()

func _copy_collection(category):
	chosen_collection._category_id = category._collection_id
	chosen_collection._is_category = category._is_category
	chosen_collection._name = category._name
	chosen_collection._description = category._description
	chosen_collection._difficulty = category._difficulty
	chosen_collection._public = category._public
	chosen_collection._learning_progress = category._learning_progress
	chosen_collection._modifiable = category._modifiable

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
	Tabs.current_tab = 2

func _on_get_collections_request_ok(response):
	for child in CollectionsContainer.get_children():
		child.queue_free()
	for item in response:
		var new_collection = category.instance()
		new_collection.init(item.category, false)
		new_collection.init_collection(item)
		CollectionsContainer.add_child(new_collection)
	
	for i in range(4):
		CollectionsContainer.add_child(empty.instance())

func _on_join_category_request_ok(response):
	network.get_categories()

func _on_get_words_request_ok(response):
	for child in WordsContainer.get_children():
		words = []
		child.queue_free()
	for item in response:
		words.append(item)
		var new_word = word.instance()
		new_word.init(item)
		WordsContainer.add_child(new_word)
	
	WordsContainer.add_child(empty.instance())
	
	var words_eng: Array = []
	var words_pl: Array = []
	for word in words:
		words_eng.append(word["engTranslation"])
		words_pl.append(word["plTranslation"])
	if words_eng.size() > 1 && words_pl.size() > 1:
		Main.init(words_eng, words_pl)
	if collection_chosen:
		Tabs.current_tab = 4

func _on_choose_collection(collection):
	_copy_collection(collection)
	CollectionName.text = chosen_collection._name
	CollectionDescription.text = chosen_collection._description
	CollectionIsPublic.pressed = chosen_collection._public
	network.get_words(chosen_collection._category_id)
	Tabs.current_tab = 3

func _on_play_collection(collection):
	_copy_collection(collection)
	network.get_words(chosen_collection._category_id)
	collection_chosen = true

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
	collection_chosen = false
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


func _on_NextButton_pressed():
	if !is_playing:
		Main.play()

func _on_SwapButton_pressed():
	if !is_playing:
		Main.swap()

func _on_PlayButton_pressed():
	Buttons.visible = false
	words_eng = []
	words_pl = []
	for word in words:
		words_eng.append(word["engTranslation"])
		words_pl.append(word["plTranslation"])
	
	words_order = words_pl.duplicate(true)
	randomize()
	words_order.shuffle()
	
	if words_eng.size() > 1 && !words_order.size() > 1:
		Main.init(words_eng, words_order)
		Main.swap()
	is_playing = true
	Answers.visible = true
	
	_generate_answers()

func _generate_answers():
	if words_order.empty():
		is_playing = false
		Buttons.visible = true
		Answers.visible = false
		words_eng = []
		words_pl = []
		for word in words:
			words_eng.append(word["engTranslation"])
			words_pl.append(word["plTranslation"])
		if words_eng.size() > 1 && words_pl.size() > 1:
			Main.init(words_eng, words_pl)
		return
	
	current_word = words_order.pop_front()
	randomize()
	correct_answer_index = randi() % 4
	correct_answer = words_eng[words_pl.find(current_word)]
	
	get_node("GUI/TabContainer/Play/Answers/Answer" + String(correct_answer_index + 1)).text = correct_answer 
	
	for i in range(4):
		if i != correct_answer_index:
			randomize()
			var incorrect_answer: String = words_eng[randi() % words_eng.size()]
			while incorrect_answer == correct_answer:
				incorrect_answer = words_eng[randi() % words_eng.size()]
			get_node("GUI/TabContainer/Play/Answers/Answer" + String(i + 1)).text = incorrect_answer

func _check_answer(answer_index: int):
	var is_correct: bool
	if correct_answer_index + 1 == answer_index:
		is_correct = true
	else:
		is_correct = false
	
	var word_id: int
	for word in words:
		if word["plTranslation"] == current_word:
			word_id = word["wordId"]
	network.word_answer(chosen_collection._category_id, word_id, is_correct)
	
	Main.play()
	_generate_answers()

func _on_Answer1_pressed():
	_check_answer(1)

func _on_Answer2_pressed():
	_check_answer(2)

func _on_Answer3_pressed():
	_check_answer(3)

func _on_Answer4_pressed():
	_check_answer(4)
