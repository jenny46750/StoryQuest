# SPDX-License-Identifier: MPL-2.0
extends Node2D

const NEXT := "res://scenes/quests/story_quests/forja_jenny/episodios/jardines.tscn"
const HERO := preload("res://scenes/quests/story_quests/forja_jenny/episodios/arte/walk.png")
const BAT := preload("res://scenes/quests/story_quests/forja_jenny/episodios/arte/murcielago.png")
const GATES := [378.0, 645.0, 928.0]
const RUNES := [255.0, 792.0]
var x := 108.0
var elapsed := 0.0
var activated := [false, false]
var message := "Activa las dos losas de luz y cruza las tres puertas."
var cooldown := 0.0

func bat_position() -> Vector2:
	var angle := elapsed * 1.8
	return Vector2(520 + sin(angle) * 62, 320 + cos(angle) * 90)

func phase(index: int) -> float:
	return fmod(elapsed + index * 0.78, 3.8)

func _physics_process(delta: float) -> void:
	elapsed += delta
	cooldown = maxf(0, cooldown - delta)
	var step := Input.get_axis("move_left", "move_right") * 245 * delta
	x = clampf(x + step, 88, 1180)
	var bat := bat_position()
	var threatened := absf(x - bat.x) < 130
	var cue := &"batalla" if threatened else &"calma"
	if $BackgroundMusic.clip != cue:
		$BackgroundMusic.set_clip(cue)
	if cooldown <= 0 and absf(x - bat.x) < 34 and bat.y > 372:
		x = 414
		cooldown = 1.2
		message = "El murciélago baja en picado. Cruza cuando vuelva a subir."
	for i in GATES.size():
		if absf(GATES[i] - x) < 24 and phase(i) < 1.45 and cooldown <= 0:
			x = 108
			cooldown = 0.6
			message = "La puerta te devolvió a la entrada. Las losas encendidas conservan su luz."
			break
	for i in RUNES.size():
		if absf(RUNES[i] - x) < 32 and Input.is_action_just_pressed("interact"):
			activated[i] = true
			message = "Losa encendida. Observa el arco siguiente antes de cruzar."
	if x > 1110:
		if activated.all(func(on): return on):
			set_physics_process(false)
			get_tree().change_scene_to_file.call_deferred(NEXT)
		else:
			message = "El portal necesita las dos losas. Acércate a cada rombo y pulsa Espacio."
	queue_redraw()

func label(pos: Vector2, value: String, size_: int, ink: Color) -> void:
	draw_string(ThemeDB.fallback_font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size_,ink)

func _draw() -> void:
	draw_rect(Rect2(-200,-200,1900,1200),Color("#162531"))
	label(Vector2(76,70),"I   /   El Vestíbulo Despierto",38,Color("#f7dfac"))
	label(Vector2(76,111),message,21,Color("#c3d9d0"))
	for i in 14:
		var cx := float(i*105)
		draw_rect(Rect2(cx,228,33,222),Color("#38494e"))
		draw_rect(Rect2(cx-6,219,45,12),Color("#617477"))
		draw_arc(Vector2(cx+68,228),51,PI,TAU,28,Color("#475d61"),8,true)
	draw_rect(Rect2(60,454,1160,85),Color("#4c5150"))
	for i in 21:
		draw_line(Vector2(i*60,455),Vector2(i*60-43,537),Color("#2e4145"),2)
	for i in RUNES.size():
		var at := Vector2(RUNES[i],449)
		var ink := Color("#92f4d5") if activated[i] else Color("#e6b85c")
		draw_colored_polygon(PackedVector2Array([at+Vector2(-24,0),at+Vector2(0,-12),at+Vector2(24,0),at+Vector2(0,9)]),ink)
		label(at+Vector2(-30,49),"LOSA %d" % (i+1),15,ink)
	for i in GATES.size():
		var gx: float = GATES[i]
		var value := phase(i)
		var ink := Color("#ff855e") if value<1.45 else Color("#efc87a") if value>3.25 else Color("#74d2b5")
		draw_arc(Vector2(gx,355),39,PI,TAU,32,ink,5,true)
		draw_line(Vector2(gx-39,355),Vector2(gx-39,453),ink,4)
		draw_line(Vector2(gx+39,355),Vector2(gx+39,453),ink,4)
		if value<1.45:
			for j in 5:
				draw_line(Vector2(gx-24+j*12,353),Vector2(gx-24+j*12,449),ink,3)
	var bat := bat_position()
	draw_texture_rect_region(BAT,Rect2(bat - Vector2(48,30),Vector2(96,96)),Rect2(96 * (int(elapsed * 8) % 4),0,96,96))
	label(Vector2(1064,397),"JARDINES →",19,Color("#9ef3dc"))
	draw_texture_rect_region(HERO,Rect2(x-64,344,128,128),Rect2(192 * (int(elapsed * 8) % 4),0,192,192))
	label(Vector2(76,622),"← →   Caminar       ESPACIO   Activar losa       Verde: pasa · Rojo: espera",23,Color("#e7dfc6"))
