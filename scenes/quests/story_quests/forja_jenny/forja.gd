# SPDX-License-Identifier: MPL-2.0
extends Node2D

@onready var puzzle: SequencePuzzle = $OnTheGround/SequencePuzzle
@onready var fire: Node2D = $OnTheGround/Sello
@onready var hint: Label = $ScreenOverlay/Instruccion
var signature: Array[StringName] = []
var premio := false

func _ready() -> void:
	puzzle.step_solved.connect(_on_step)
	puzzle.solved.connect(_on_solved)
	for rune in puzzle.get_node("Objects").get_children():
		rune.kicked.connect(_record_strike.bind(rune.name))
		rune.interact_area.action_text = "Golpear runa"
	_on_step(-1)

func _on_step(index: int) -> void:
	if index == -1:
		hint.text = "FORJA ANCESTRAL  ·  IV\nHaz clic en LUNA para entrar en la cripta. Espacio sirve para tocar las runas."
	elif index == 0:
		hint.text = "Primer sello abierto. Consulta el segundo pedestal."

func _on_solved() -> void:
	fire.get_node("AnimationPlayer").play("apagar")
	hint.text = "El fuego se retira. Recoge el fragmento: la víbora custodia el paso al Santuario."

func _record_strike(rune: StringName) -> void:
	if premio:
		return
	signature.append(rune)
	if signature.size() > 3:
		signature.pop_front()
	if signature == [&"Red", &"Blue", &"Red"]:
		premio = true
		fire.insignia = true
		hint.text = "Insignia del herrero obtenida. Tu marca brilla sobre el altar."

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var moon: Node2D = puzzle.get_node("Objects/Blue")
		var local_hit: Vector2 = moon.get_global_transform_with_canvas().affine_inverse() * event.position
		if Rect2(-48, -72, 96, 128).has_point(local_hit):
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file.call_deferred("res://scenes/quests/story_quests/forja_jenny/cripta.tscn")

