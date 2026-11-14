extends Node2D

var cruce_completado := false

const FLOOR := Rect2(126, 340, 1028, 80)
const GOLD := Color("#efc779")

func _draw() -> void:
	draw_rect(Rect2(-1800,-1200,4800,3200), Color("#102835"))
	for row in range(12):
		for col in range(18):
			var p := Vector2(col * 82 + (row % 2) * 35, row * 50 + 22)
			draw_line(p, p + Vector2(23,0), Color("#224451"), 2)
	draw_rect(FLOOR.grow(8), Color("#283541"))
	draw_rect(FLOOR, Color("#676456"))
	for x in range(128,1152,56):
		draw_line(Vector2(x,340),Vector2(x,420),Color("#483f3d"),3)
	for y in [338,422]:
		draw_line(Vector2(126,y),Vector2(1154,y),GOLD,3)
	for x in range(478, 741, 20):
		draw_line(Vector2(x,329), Vector2(x+11,329), GOLD,3)
	draw_arc(Vector2(1030,383),22,0,TAU,36,GOLD,4)
	draw_circle(Vector2(1030,383),6,GOLD)

func _on_arrival(body: Node2D) -> void:
	if body == $David and $Compuerta.opened and not cruce_completado:
		cruce_completado = true
		$Estado.text = "Cruce completado   ·   Espacio para entrar al Santuario."
		$Estado.modulate = GOLD

func _lever_changed(opened: bool) -> void:
	if cruce_completado:
		return
	$Estado.text = "Compuerta abierta   ·   Cruza hasta el círculo dorado." if opened else "Compuerta cerrada   ·   Busca el mando de latón."

func _enter_tree() -> void:
	if GameState.scene == null:
		GameState.scene = PerSceneState.new(scene_file_path)

func _process(_delta: float) -> void:
	if cruce_completado and Input.is_action_just_pressed("interact"):
		set_process(false)
		var santuario := "res://scenes/quests/story_quests/forja_jenny/salida.tscn"
		GameState.set_scene(santuario)
		get_tree().change_scene_to_file.call_deferred(santuario)