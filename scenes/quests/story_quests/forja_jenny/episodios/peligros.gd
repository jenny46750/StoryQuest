# SPDX-License-Identifier: MPL-2.0
extends Node2D

@export var centros: PackedVector2Array
@export var radio := 38.0
@export var periodo := 4.2
@export var color_aviso := Color("#f7cb77")
@export var color_activo := Color("#fd754f")
@export var mensaje := "Peligro"
@onready var player: Node2D = $"../OnTheGround/Player"
var reloj := 0.0
var seguro := Vector2.ZERO
var gracia := 1.5

func _ready() -> void:
	seguro = player.global_position

func _physics_process(dt: float) -> void:
	if not is_instance_valid(player):
		return
	reloj += dt
	gracia = maxf(0, gracia-dt)
	for i in centros.size():
		if fase(i) < 1.15 and gracia <= 0 and player.global_position.distance_to(centros[i]) < radio:
			var farol := get_node_or_null("../OnTheGround/Checkpoints/Checkpoint") as Node2D
			if farol and GameState.scene and not GameState.scene.spawn_point.is_empty():
				seguro = farol.global_position + Vector2(-50, 20)
			player.global_position = seguro
			gracia = 1.5
			break
	queue_redraw()

func fase(i: int) -> float:
	return fmod(reloj + i*1.19, periodo)

func _draw() -> void:
	for i in centros.size():
		var at := centros[i]
		var p := fase(i)
		var active := p<1.15
		var ink := color_activo if active else color_aviso
		draw_arc(at,radio,0,TAU,32,Color(ink,0.65),2,true)
		if active:
			draw_circle(at,radio-3,Color(ink,0.30))
			for j in 5:
				var v := Vector2.from_angle(j*TAU/5+reloj)*radio*0.5
				draw_line(at+v,at+v+Vector2(3,-14),ink,3)
		elif p > periodo-0.85:
			draw_arc(at,radio-7,0,TAU,32,ink,4,true)
		draw_string(ThemeDB.fallback_font,at+Vector2(-45,radio+15),mensaje,HORIZONTAL_ALIGNMENT_CENTER,90,13,ink)
