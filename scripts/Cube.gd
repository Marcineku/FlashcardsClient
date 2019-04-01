tool
extends Spatial

onready var Front: MeshInstance = $Front
onready var Left: MeshInstance = $Left
onready var CurrentText: Viewport = $Front/CurrentText
onready var PreviousText: Viewport = $Left/PreviousText
onready var Anim: AnimationPlayer = $Anim

func _ready() -> void:
	Front.get_surface_material(0).albedo_texture = CurrentText.get_texture()
	Left.get_surface_material(0).albedo_texture = PreviousText.get_texture()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		Anim.play("Rotation")