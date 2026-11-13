# SPDX-License-Identifier: MPL-2.0
extends Node2D

const MAP := [
	"###################",
	"#.....#...........#",
	"#.###.#.###.#####.#",
	"#.......#...#.....#",
	"#.#.###.#.#.#.###.#",
	"#.#.....#.#...#...#",
	"#.#.#.#...###.#.#.#",
	"#.....#.......#...#",
	"###################"
]
const CELL := 60
const OFFSET := Vector2(70, 108)
const EXIT := Vector2i(17, 1)
const START := Vector2i(1, 1)
const GEMS := [Vector2i(1, 7), Vector2i(11, 3)]
const HERO = preload("res://scenes/quests/story_quests/forja_jenny/episodios/arte/walk.png")
const RETURN_SCENE := "res://scenes/quests/story_quests/forja_jenny/story escena intro.tscn"
const DIRS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
var hero := Vector2.ZERO
var head := Vector2.ZERO
var waypoint := Vector2i(17, 7)
const VIPER := preload("res://scenes/quests/story_quests/forja_jenny/episodios/arte/vibora.png")
var facing_left := false
var rumbo_al_santuario := false
var remaining := GEMS.duplicate()
var elapsed := 0.0
var outcome := ""
var delay := 0.0

func center(cell: Vector2i) -> Vector2:
	return OFFSET + (Vector2(cell) + Vector2(0.5,0.5)) * CELL

func cell_at(point: Vector2) -> Vector2i:
	return Vector2i(((point - OFFSET) / CELL).floor())

func walkable(cell: Vector2i) -> bool:
	return cell.y >= 0 and cell.y < MAP.size() and cell.x >= 0 and cell.x < MAP[0].length() and MAP[cell.y][cell.x] == "."

func fits(point: Vector2) -> bool:
	for delta in [Vector2(-11,-11), Vector2(11,-11), Vector2(-11,11), Vector2(11,11)]:
		if not walkable(cell_at(point + delta)):
			return false
	return true

func _ready() -> void:
	rumbo_al_santuario = GameState.quest != null and GameState.quest.inventory.items.size() >= 3
	hero = center(START)
	head = center(waypoint)

func next_step(origin: Vector2i, target: Vector2i) -> Vector2i:
	if origin == target:
		return origin
	var queue: Array[Vector2i] = [origin]
	var parent := {origin: origin}
	var cursor := 0
	while cursor < queue.size():
		var here := queue[cursor]
		cursor += 1
		for dir: Vector2i in DIRS:
			var cell := here + dir
			if parent.has(cell) or not walkable(cell):
				continue
			parent[cell] = here
			if cell == target:
				while parent[cell] != origin:
					cell = parent[cell]
				return cell
			queue.append(cell)
	return origin

func _physics_process(dt: float) -> void:
	elapsed += dt
	if outcome == "captura":
		delay += dt
		if delay >= 1.4:
			set_physics_process(false)
			GameState.set_quest(load("res://scenes/quests/story_quests/forja_jenny/quest.tres"))
			GameState.quest.challenge_start_scene = RETURN_SCENE
			GameState.set_scene(RETURN_SCENE)
			get_tree().change_scene_to_file(RETURN_SCENE)
		return
	if outcome == "victoria":
		if Input.is_action_just_pressed("interact"):
			set_physics_process(false)
			var next := "salida.tscn" if rumbo_al_santuario else "forja.tscn"
			get_tree().change_scene_to_file.call_deferred("res://scenes/quests/story_quests/forja_jenny/" + next)
		return
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	var movement := direction * 230.0 * dt
	if fits(hero + Vector2(movement.x,0)):
		hero.x += movement.x
	if fits(hero + Vector2(0,movement.y)):
		hero.y += movement.y
	if elapsed > 1.5:
		if head.distance_to(center(waypoint)) < 0.1:
			waypoint = next_step(waypoint,cell_at(hero))
		var dest := center(waypoint)
		if waypoint == cell_at(hero) and cell_at(head) == waypoint:
			dest = hero
		if absf(dest.x - head.x) > 0.1:
			facing_left = dest.x < head.x
		head = head.move_toward(dest, (76.0 + 8.0 * (2 - remaining.size())) * dt)
	if head.distance_to(hero) < 23:
		outcome = "captura"
	else:
		for gem: Vector2i in remaining.duplicate():
			if hero.distance_to(center(gem)) < 23:
				remaining.erase(gem)
		if remaining.is_empty() and hero.distance_to(center(EXIT)) < 24:
			outcome = "victoria"
	queue_redraw()

func label(at: Vector2, value: String, size_: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size_,color)

func _draw() -> void:
	draw_rect(Rect2(-1200,-800,4000,2400),Color("#10191f"))
	label(Vector2(72,43),"La cripta lunar",32,Color("#f5e7bb"))
	label(Vector2(72,78),"Víbora lunar: «Dos cristales abren mi puerta, si llegas antes que yo».   •   Mover: flechas",21,Color("#b5d4d1"))
	label(Vector2(1000,56),"CRISTALES   %d / 2" % (2-remaining.size()),20,Color("#f6d58a"))
	for y in MAP.size():
		for x in MAP[y].length():
			var cell := Vector2i(x,y)
			var corner := center(cell)-Vector2(30,30)
			var rect := Rect2(corner,Vector2(60,60))
			if walkable(cell):
				draw_rect(rect,Color("#24343c") if (x+y)%2 else Color("#293a41"))
				draw_line(corner+Vector2(5,57),corner+Vector2(55,57),Color("#31454b"))
			else:
				draw_rect(rect,Color("#17252f"))
				draw_rect(Rect2(corner+Vector2(2,1),Vector2(56,46)),Color("#465766"))
				draw_rect(Rect2(corner+Vector2(3,3),Vector2(54,5)),Color("#647984"))
				draw_line(corner+Vector2(2,26),corner+Vector2(58,26),Color("#293c48"),2)
				draw_line(corner+Vector2(22,8),corner+Vector2(22,25),Color("#344854"),2)
	var exit_pos := center(EXIT)
	var glow := Color("#85f5de") if remaining.is_empty() else Color("#958b7f")
	draw_arc(exit_pos,22,0,TAU,40,glow,3,true)
	draw_arc(exit_pos,15,elapsed,elapsed+4.4,24,glow,2,true)
	for gem: Vector2i in remaining:
		var at := center(gem)+Vector2(0,3*sin(elapsed*3))
		draw_circle(at,20,Color("#224e58"))
		draw_colored_polygon(PackedVector2Array([at+Vector2(0,-15),at+Vector2(10,0),at+Vector2(0,15),at+Vector2(-10,0)]),Color("#87f8da"))
		draw_line(at+Vector2(-2,-8),at+Vector2(-5,1),Color.WHITE,2)
	draw_set_transform(head, 0.0, Vector2(-1 if facing_left else 1, 1))
	draw_texture_rect_region(VIPER, Rect2(-33,-33,66,66), Rect2(120 * (int(elapsed*7) % 4),0,120,120))
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(HERO,Rect2(hero-Vector2(47,57),Vector2(94,94)),Rect2(192 * (int(elapsed * 8) % 4),0,192,192))
	if outcome != "":
		draw_rect(Rect2(260,275,760,150),Color("#13212bf7"))
		var won := outcome=="victoria"
		label(Vector2(310,338),"¡Escapaste de la serpiente!" if won else "La serpiente te atrapó",36,Color("#ffe09c"))
		label(Vector2(310,385),("Espacio para subir al Santuario." if rumbo_al_santuario else "Espacio para regresar a la Forja.") if won else "Regresas al Vestíbulo…",22,Color("#e0efea"))

