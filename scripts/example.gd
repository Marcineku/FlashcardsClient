extends Control

onready var example: Label = $Label

var _example: String = ""

func _ready():
	example.text = _example

func init(text: String):
	_example = text