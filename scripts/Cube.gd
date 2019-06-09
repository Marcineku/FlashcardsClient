tool
extends Spatial

const _anim_name: String = "Rotation"

onready var Front: MeshInstance = $Front
onready var Left: MeshInstance = $Left
onready var CurrentTextViewport: Viewport = $Front/Viewport
onready var PreviousTextViewport: Viewport = $Left/Viewport
onready var CurrentText: Label = $Front/Viewport/CurrentText
onready var PreviousText: Label = $Left/Viewport/PreviousText
onready var Anim: AnimationPlayer = $Anim

var _anim_playing: bool = false
var _arr : PoolStringArray = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"]
var _wrd_iter: int = 0

func _ready() -> void:
	Front.get_surface_material(0).albedo_texture = CurrentTextViewport.get_texture()
	Left.get_surface_material(0).albedo_texture = PreviousTextViewport.get_texture()
	CurrentText.text = _arr[_wrd_iter]

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") && !_anim_playing:
		_wrd_iter += 1
		if _wrd_iter >= _arr.size():
			_wrd_iter = 0
		PreviousText.text = CurrentText.text
		CurrentText.text = _arr[_wrd_iter]
		Anim.play(_anim_name)

func _on_Anim_animation_started(anim_name: String) -> void:
	if anim_name == _anim_name:
		_anim_playing = true

func _on_Anim_animation_finished(anim_name: String) -> void:
	if anim_name == _anim_name:
		_anim_playing = false

func play() -> void:
	if !_anim_playing:
		_wrd_iter += 1
		if _wrd_iter >= _arr.size():
			_wrd_iter = 0
		PreviousText.text = CurrentText.text
		CurrentText.text = _arr[_wrd_iter]
		Anim.play(_anim_name)