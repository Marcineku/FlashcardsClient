extends Control

onready var eng_trans: Label = $VBoxContainer/engTrans
onready var pl_trans: Label = $VBoxContainer/plTrans
onready var correct_answers: Label = $VBoxContainer/correctAnswers
onready var incorrect_answers: Label = $VBoxContainer/incorrectAnswers
onready var difficulty: Label = $VBoxContainer/difficulty
onready var learned: Label = $VBoxContainer/learned

var _word_id: int = -1
var _eng_trans: String = ""
var _pl_trans: String = ""
var _correct_answers: float = 0.0
var _incorrect_answers: float = 0.0
var _difficulty: float = 0.0
var _learned: bool = false
var _engExamples: Array

func _ready():
	eng_trans.text = _eng_trans
	pl_trans.text = _pl_trans
	correct_answers.text = String(_correct_answers)
	incorrect_answers.text = String(_incorrect_answers)
	difficulty.text = String(_difficulty)
	learned.text = String(_learned)

func init(data: Dictionary):
	_word_id = data["wordId"]
	_eng_trans = data["engTranslation"]
	_pl_trans = data["plTranslation"]
	_correct_answers = data["correctAnswers"]
	_incorrect_answers = data["incorrectAnswers"]
	_difficulty = data["difficulty"]
	_learned = data["learned"]
	_engExamples = data["engExamples"]


func _on_VBoxContainer_pressed():
	network.choose_word(self)
