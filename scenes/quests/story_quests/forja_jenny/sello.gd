# SPDX-License-Identifier: MPL-2.0
extends Node2D

@export var intensidad: float = 1.0
var insignia := false
var tiempo := 0.0

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, 55, 0, TAU, 48, Color("#ffd580"), 3, true)
	for i in range(11):
		var x := (i - 5) * 9.0
		var h := (28.0 + 9.0 * sin(tiempo * 5.0 + i)) * intensidad
		if h > 0.5:
			draw_colored_polygon(PackedVector2Array([Vector2(x - 7, 1), Vector2(x + 4, -h), Vector2(x + 7, 1)]), Color("#f66b48"))
			draw_line(Vector2(x, 1), Vector2(x + 2, -h * 0.57), Color("#ffd179"), 3)
	if insignia:
		draw_colored_polygon(PackedVector2Array([Vector2(0,-82), Vector2(12,-66), Vector2(0,-50), Vector2(-12,-66)]),Color("#ffd580"))
