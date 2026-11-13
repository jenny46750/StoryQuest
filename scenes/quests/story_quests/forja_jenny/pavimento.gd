# SPDX-License-Identifier: MPL-2.0
extends Node2D

const BRASS := Color("#cf9f56")
const STONE := Color("#4c464b")
const NAMES := ["LUNA", "SOL", "HOJA", "BRASA"]
const CENTERS := [Vector2(325,489),Vector2(501,469),Vector2(589,459),Vector2(765,439)]

func _draw() -> void:
	# The stone dais sits under the interactable runes; it carries no extra collision.
	var outline := PackedVector2Array([Vector2(266,479), Vector2(752,413), Vector2(814,451), Vector2(332,525)])
	draw_colored_polygon(outline, STONE)
	for i in range(outline.size()):
		draw_line(outline[i], outline[(i + 1) % outline.size()], BRASS, 3, true)
	for i in range(CENTERS.size()):
		var center: Vector2 = CENTERS[i]
		draw_arc(center, 31, 0, TAU, 32, Color("#9f906d"), 2, true)
		draw_string(ThemeDB.fallback_font, center + Vector2(-35, 49), NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, 70, 14, Color("#fff0be"))
