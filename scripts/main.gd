extends Spatial

const _anim_name: String = "Rotation"

onready var Front: MeshInstance = $Cube/Front
onready var Left: MeshInstance = $Cube/Left
onready var CurrentTextViewport: Viewport = $Cube/Front/Viewport
onready var PreviousTextViewport: Viewport = $Cube/Left/Viewport
onready var CurrentText: Label = $Cube/Front/Viewport/CurrentText
onready var PreviousText: Label = $Cube/Left/Viewport/PreviousText
onready var Anim: AnimationPlayer = $Cube/Anim

var _anim_playing: bool = false
var _arr : PoolStringArray = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"]

var _words_eng: PoolStringArray
var _words_pl: PoolStringArray
var _is_eng_displaying: bool = true
var _wrd_iter: int = 0

func _ready() -> void:
	Front.get_surface_material(0).albedo_texture = CurrentTextViewport.get_texture()
	Left.get_surface_material(0).albedo_texture = PreviousTextViewport.get_texture()
	CurrentText.text = _arr[_wrd_iter]

func _on_Anim_animation_started(anim_name: String) -> void:
	if anim_name == _anim_name:
		_anim_playing = true

func _on_Anim_animation_finished(anim_name: String) -> void:
	if anim_name == _anim_name:
		_anim_playing = false

func init(words_eng: Array, words_pl: Array):
	_words_eng = words_eng.duplicate(true)
	_words_pl = words_pl.duplicate(true)
	_is_eng_displaying = true
	_wrd_iter = 0
	if _is_eng_displaying:
		CurrentText.text = _words_eng[_wrd_iter]
	else:
		CurrentText.text = _words_pl[_wrd_iter]

func swap() -> void:
	if _words_eng.size() <= 1 || _words_pl.size() <= 1:
		return
	
	if _is_eng_displaying:
		_is_eng_displaying = false
		CurrentText.text = _words_pl[_wrd_iter]
	else:
		_is_eng_displaying = true
		CurrentText.text = _words_eng[_wrd_iter]

func play() -> void:
	if _words_eng.size() <= 1 || _words_pl.size() <= 1:
		return
	
	_wrd_iter += 1
	if _wrd_iter >= _words_eng.size():
		_wrd_iter = 0
	PreviousText.text = CurrentText.text
	
	if _is_eng_displaying:
		CurrentText.text = _words_eng[_wrd_iter]
	else:
		CurrentText.text = _words_pl[_wrd_iter]
	
	Anim.play(_anim_name)