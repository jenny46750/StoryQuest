# SPDX-License-Identifier: MPL-2.0
extends Node2D

const HERO := preload("../arte/walk.png")
const MUSIC := preload("cielo.wav")
const TONES := [preload("mecha.wav"), preload("cauce.wav"), preload("yunque.wav")]
const MISS := preload("eco.wav")
const DAWN := preload("amanecer.wav")
const HUB := Vector2(640, 346)
const ALTARS := [Vector2(351,386), Vector2(639,188), Vector2(930,386)]
const NAMES := ["Farol", "Cauce", "Yunque"]
const INKS := [Color("#f4bf69"), Color("#88e1ed"), Color("#efa195")]
const OPENING := [
	["Mara", "David, solo quedan dos peldaños secos. Por la rejilla veo tu linterna."],
	["David", "El cuaderno tiene tres dibujos: una mecha, una ola y un martillo. Son las estaciones del regulador."],
	["Inés", "Alinea los tres sellos en ese orden. Cuando coincidan los anillos, pulsa Espacio. Yo vigilo la marea."]
]
const ANSWERS := [
	["Inés", "¡Tengo tu señal en el farol! He avisado a los botes. Ya pueden acercarse al pozo."],
	["Mara", "El agua me llegaba al cuello. Ahora veo el escalón. ¡Sigue, David!"],
	["Remachador", "Cable tenso. Lleva la aguja al eje central y podremos izarlos."]
]
const ENDING := [
	["David", "La aguja entra hasta el fondo. Una vuelta más y el agua saldrá por el canal viejo. ¡Ahora!"],
	["Mara", "Primero la cuerda al herido. Después salgo yo. Cuenta tres golpes, como prometiste."],
	["Inés", "Uno. Dos… ¡tres! Aquí vienen. David, tu cuaderno se está empapando."],
	["David", "Al amanecer extendimos sus hojas en el muelle. Mara añadió una línea al mapa: una salida para la próxima expedición."]
]
enum Phase { INTRO, PLAY, MEMORY, ENDING, FIN }
var phase := Phase.INTRO
var line := 0
var seals := 0
var pos := HUB + Vector2(0,115)
var elapsed := 0.0
var pulse := 0.0
var moving := false
var hint := ""
var hint_time := 0.0
var facing_left := false

func _ready() -> void:
	$Musica.stream = MUSIC
	$Musica.finished.connect($Musica.play)
	$Musica.play()

func sound(stream: AudioStream) -> void:
	$VozDelOrbe.stream = stream
	$VozDelOrbe.play()

func _physics_process(dt: float) -> void:
	elapsed += dt
	hint_time -= dt
	moving = false
	if phase == Phase.PLAY:
		pulse = fmod(pulse + dt, 2.4)
		var direction := Input.get_vector("move_left","move_right","move_up","move_down")
		var candidate := pos + direction * 235 * dt
		var ellipse := (candidate - HUB) / Vector2(405,178)
		if ellipse.length_squared() <= 1:
			pos = candidate
			moving = direction.length_squared() > 0
		if absf(direction.x) > 0.1:
			facing_left = direction.x < 0
	if Input.is_action_just_pressed("interact"):
		act()
	queue_redraw()

func act() -> void:
	match phase:
		Phase.INTRO, Phase.ENDING:
			line += 1
			if phase == Phase.INTRO and line == OPENING.size():
				phase = Phase.PLAY
				line = 0
			elif phase == Phase.ENDING and line == ENDING.size():
				phase = Phase.FIN
		Phase.MEMORY:
			phase = Phase.PLAY
			pulse = 0
		Phase.PLAY:
			if seals == 3 and pos.distance_to(HUB) < 50:
				phase = Phase.ENDING
				line = 0
				sound(DAWN)
				return
			for i in ALTARS.size():
				if pos.distance_to(ALTARS[i]) > 52:
					continue
				if i != seals:
					hint = "Este sello ya canta." if i < seals else "Aún falta el eco del " + NAMES[seals] + "."
				elif pulse < 1.45 or pulse > 2.16:
					hint = "Espera a que coincidan los anillos y aparezca TOCA."
					sound(MISS)
				else:
					sound(TONES[i])
					seals += 1
					phase = Phase.MEMORY
					hint = ""
				hint_time = 2.5
				return
		Phase.FIN:

			restart_quest()

func restart_quest() -> void:
	var quest = load("res://scenes/quests/story_quests/forja_jenny/quest.tres")
	GameState.set_quest(quest)
	GameState.quest.challenge_start_scene = quest.first_scene
	GameState.set_scene(quest.first_scene)
	get_tree().change_scene_to_file.call_deferred(quest.first_scene)

func txt(at: Vector2, value: String, size_: int, ink: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size_, ink)

func _draw() -> void:
	var dawn := phase == Phase.ENDING or phase == Phase.FIN
	draw_rect(Rect2(-200,-200,1680,1120), Color("#382f4b") if dawn else Color("#101d31"))
	for i in 96:
		var star := Vector2(fmod(i*137.3,1280),fmod(i*i*2.61,410))
		draw_circle(star,1.0+i%3*.4,Color(.81,.86,.94,.45+.3*sin(elapsed+i)))
	draw_circle(Vector2(1090,131),44,Color("#ffcf8a") if dawn else Color("#d9d5ba"))
	for i in 14:
		var x := float(i*112-90)
		var peak := Vector2(x+72,209+62*sin(i*4.4))
		draw_colored_polygon(PackedVector2Array([Vector2(x-92,425),peak,Vector2(x+236,425)]),Color("#414354") if dawn else Color("#26354b"))
	for i in 3:
		draw_set_transform(HUB+Vector2(0,14-i*7),0,Vector2(1,.455))
		draw_circle(Vector2.ZERO,438-i*7,[Color("#2b2938"),Color("#716350"),Color("#343d48")][i])
	draw_set_transform(Vector2.ZERO)
	# Broken supports silhouette the high terrace against the valley.
	for edge in [180, 1058]:
		draw_rect(Rect2(edge,337,42,155),Color("#302f40"))
		draw_rect(Rect2(edge-7,331,56,10),Color("#726552"))
		draw_rect(Rect2(edge+5,353,5,119),Color("#494558"))
	for i in 14:
		var a := i*TAU/14
		var b := (i+1)*TAU/14
		var near := Vector2(cos(a)*345,sin(a)*156)
		var far := Vector2(cos(a)*416,sin(a)*188)
		draw_line(HUB+near,HUB+far,Color("#50515a"),2)
		var chain := PackedVector2Array()
		for j in 9:
			var phi := lerpf(a,b,j/8.0)
			chain.append(HUB+Vector2(cos(phi)*346,sin(phi)*156))
		draw_polyline(chain, Color("#655c56"),2,true)
	for i in 28:
		var a := i*TAU/28
		var mark := HUB+Vector2(cos(a)*398,sin(a)*179)
		draw_circle(mark,2.5,Color("#988065"))
	for i in 3:
		var at: Vector2 = ALTARS[i]
		var ink: Color = INKS[i]
		draw_line(HUB,at,ink.darkened(.55) if i >= seals else ink,4,true)
		draw_circle(at,31,Color("#192638"))
		draw_arc(at,29,0,TAU,48,ink,3,true)
		if i == seals and phase == Phase.PLAY:
			var r := lerpf(52,19,pulse/2.4)
			draw_arc(at,r,0,TAU,48,Color.WHITE,2,true)
		txt(at+Vector2(-5,7),str(i+1),18,ink)
		txt(at+Vector2(-30,-39),NAMES[i],18,ink)
	var lit := seals == 3
	draw_circle(HUB,29+3*sin(elapsed*2),Color("#6f827d") if lit else Color("#293142"))
	draw_arc(HUB,30,0,TAU,48,Color("#ffe2a5"),3,true)
	for i in seals:
		var a := elapsed*.8 + i*TAU/3
		draw_circle(HUB+Vector2(cos(a),sin(a))*14,6,INKS[i])
	draw_set_transform(pos,0,Vector2(-1 if facing_left else 1,1))
	draw_texture_rect_region(HERO,Rect2(-66,-93,132,132),Rect2(192*(int(elapsed*8)%4 if moving else 0),0,192,192))
	draw_set_transform(Vector2.ZERO)
	txt(Vector2(52,52),"V   /   Santuario de la Cima",33,Color("#ffe5ae"))
	txt(Vector2(1010,51),"SELLOS     %d  /  3" % seals,20,Color("#ffdfa0"))
	draw_rect(Rect2(48,553,1184,141),Color("#101825"))
	draw_rect(Rect2(49,554,5,139),Color("#dfa969"))
	var speaker := ""
	var words := ""
	var foot := "ESPACIO   Continuar"
	match phase:
		Phase.INTRO:
			speaker = OPENING[line][0]
			words = OPENING[line][1]
		Phase.MEMORY:
			speaker = ANSWERS[seals-1][0]
			words = ANSWERS[seals-1][1]
		Phase.ENDING:
			speaker = ENDING[line][0]
			words = ENDING[line][1]
		Phase.FIN:
			speaker = "FIN   /   David y la aguja del estuario"
			words = "Expedición rescatada. La aguja volvió a señalar el canal seguro."
			foot = "ESPACIO   Volver a jugar"
		Phase.PLAY:
			speaker = "Monta la aguja en el eje central" if lit else "Acércate al sello %d · %s" % [seals+1,NAMES[seals]]
			words = "Pulsa Espacio en el eje para abrir el desagüe y rescatar a Mara." if lit else "Sigue la línea hasta el sello. Pulsa Espacio cuando el anillo alcance su borde."
			if hint_time > 0 and not hint.is_empty():
				words = hint
			elif not lit and pos.distance_to(ALTARS[seals]) <= 52 and pulse >= 1.45 and pulse <= 2.16:
				words = "¡TOCA!   Pulsa Espacio ahora."
			foot = "FLECHAS   Caminar       ESPACIO   Interactuar"
	txt(Vector2(76,584),speaker,22,Color("#ffd18b"))
	draw_multiline_string(ThemeDB.fallback_font, Vector2(76,617), words, HORIZONTAL_ALIGNMENT_LEFT,1125,21,2)
	txt(Vector2(76,679),foot,16,Color("#b5d6d8"))


