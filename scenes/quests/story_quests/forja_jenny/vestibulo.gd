# SPDX-License-Identifier: MPL-2.0
# Escena y efecto creados con asistencia de IA para el prototipo del Grupo 8.
extends Control

@onready var ATLAS: Texture2D = load("res://scenes/quests/story_quests/forja_jenny/orbe.png")
const FRAME_SIZE = Vector2(640, 280)
const TEXTS = [
	"Al caer la noche, una bengala roja ilumina el estuario. La expedición de Mara sigue bajo tierra y sube la marea.",
	"David: «Tres muescas en el cristal. Abuelo dibujó esta pieza en su cuaderno de sondajes».",
	"David deja caer el cristal en el tubo de señales. Desde las paredes llegan tres golpes.",
	"Mara, por radio: «¡David! El pozo está inundado. Desde la cima puedes abrir el desagüe. Busca las tres piezas de la aguja»."
]
const ACTIONS = ["Examinar el cristal", "Probar el tubo", "Escuchar la señal…", "Entrar al observatorio"]
var stage := 0
var elapsed := 0.0
var frame := 0

func _ready() -> void:
	$Action.pressed.connect(_advance)
	$Action.grab_focus()
	_sync()

func _sync() -> void:
	$Dialogue.text = TEXTS[stage]
	$Action.text = ACTIONS[stage]
	$Action.disabled = stage == 2
	if not $Action.disabled:
		$Action.grab_focus()
	queue_redraw()

func _advance() -> void:
	if stage == 2:
		return
	if stage == 3:
		get_tree().change_scene_to_file("res://scenes/quests/story_quests/forja_jenny/episodios/umbrales.tscn")
		return
	stage += 1
	frame = stage
	elapsed = 0.0
	_sync()

func _process(delta: float) -> void:
	if stage != 2:
		return
	elapsed += delta
	frame = mini(45, 2 + int(elapsed * 16.0))
	if elapsed >= 2.75:
		stage = 3
		frame = 46
		_sync()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0e171c"))
	var origin := Vector2(frame % 8, floori(frame / 8.0)) * FRAME_SIZE
	draw_texture_rect_region(ATLAS, Rect2(32, 95, 1216, 532), Rect2(origin, FRAME_SIZE))

