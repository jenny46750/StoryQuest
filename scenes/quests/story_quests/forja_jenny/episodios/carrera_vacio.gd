extends Node2D

const HERO := preload("arte/walk.png")
const LOCK_SCENE := "res://scenes/quests/story_quests/forja_jenny/esclusa/esclusa.tscn"
const STONE := Color("#25304d")
const EDGE := Color("#75efdc")
const VOID_GLOW := Color("#b887fc")
const PAPER := Color("#f0e8cf")
const BASE_Y := 476.0
const SCREEN_X := 228.0
const FINISH := 4860.0
const BEACON := 2480.0
const GAPS := [Vector2(670,785), Vector2(1210,1350), Vector2(1750,1905),
	Vector2(2150,2270), Vector2(2790,2945), Vector2(3290,3450),
	Vector2(3750,3880), Vector2(4270,4435)]
enum Phase { BRIEFING, RUNNING, FALLEN, ARRIVED }
var phase := Phase.BRIEFING
var distance := 0.0
var height := 0.0
var lift := 0.0
var grounded := true
var beacon_lit := false
var elapsed := 0.0

func gap_at(x: float) -> bool:
	for gap: Vector2 in GAPS:
		if x > gap.x and x < gap.y:
			return true
	return false

func begin_run() -> void:
	distance = BEACON if beacon_lit else 0.0
	height = 0
	lift = 0
	grounded = true
	phase = Phase.RUNNING
	$BackgroundMusic.set_clip(&"batalla")

func advance(dt: float, jump: bool) -> void:
	if grounded and jump:
		lift = 685
		grounded = false
	distance += (360 if beacon_lit else 320) * dt
	if grounded and gap_at(distance):
		grounded = false
	if not grounded:
		var previous := height
		lift -= 1800 * dt
		height += lift * dt
		if previous >= 0 and height <= 0 and not gap_at(distance):
			height = 0
			lift = 0
			grounded = true
	if distance >= BEACON and grounded:
		beacon_lit = true
	if height < -145:
		phase = Phase.FALLEN
		$BackgroundMusic.set_clip(&"calma")
	elif distance >= FINISH and grounded:
		phase = Phase.ARRIVED
		$BackgroundMusic.set_clip(&"calma")

func _physics_process(dt: float) -> void:
	elapsed += dt
	var pressed := Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("move_up")
	match phase:
		Phase.BRIEFING, Phase.FALLEN:
			if pressed: begin_run()
		Phase.RUNNING:
			advance(dt, pressed)
		Phase.ARRIVED:
			if pressed:
				set_physics_process(false)
				GameState.set_scene(LOCK_SCENE)
				get_tree().change_scene_to_file.call_deferred(LOCK_SCENE)
	queue_redraw()

func caption(x: float, y: float, words: String, size_px: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(x,y), words, HORIZONTAL_ALIGNMENT_LEFT,-1,size_px,color)

func platform(left: float, right: float) -> void:
	var a := maxf(0, SCREEN_X + left - distance)
	var b := minf(1280, SCREEN_X + right - distance)
	if b <= a: return
	draw_colored_polygon(PackedVector2Array([Vector2(a,BASE_Y),Vector2(b,BASE_Y),Vector2(b,BASE_Y+26),
		Vector2(lerpf(a,b,0.68),BASE_Y+64),Vector2(a,BASE_Y+40)]),STONE)
	draw_line(Vector2(a,BASE_Y),Vector2(b,BASE_Y),EDGE,4)

func _draw() -> void:
	draw_rect(Rect2(-1400,-900,4100,2600),Color("#101124"))
	for i in 24:
		var x := fposmod(i*137.0-distance*0.12,1310)
		draw_circle(Vector2(x,100+(i*71)%420),1+i%2,Color("#9893bd"))
	for i in 3:
		draw_arc(Vector2(765,304),58+i*15,elapsed*.15+i,elapsed*.15+i+4.9,50,Color("#473963"),2)
	draw_circle(Vector2(765,304),52,Color("#100c20"))
	var start := -1800.0
	for gap: Vector2 in GAPS:
		platform(start,gap.x)
		jump_markers(gap.x)
		start = gap.y
	platform(start,FINISH+1400)
	for marker: float in [BEACON, FINISH]:
		var x := SCREEN_X+marker-distance
		draw_arc(Vector2(x,BASE_Y-44),42,PI,TAU,36,VOID_GLOW,5)
		for side in [-1,1]:
			draw_line(Vector2(x+side*42,BASE_Y-44),Vector2(x+side*42,BASE_Y),VOID_GLOW,5)
	draw_texture_rect_region(HERO,Rect2(SCREEN_X-65,BASE_Y-112-height,130,130),
		Rect2((int(elapsed*9)%4 if phase==Phase.RUNNING else 0)*192,0,192,192))
	caption(52,60,"V   /   La carrera del vacío",32,PAPER)
	caption(52,98,"FAROL DE INÉS   ·   GUARDADO" if beacon_lit else "RUMBO AL SANTUARIO",17,EDGE)
	draw_rect(Rect2(885,48,335,6),STONE)
	draw_rect(Rect2(885,48,335*minf(distance/FINISH,1),6),EDGE)
	draw_rect(Rect2(46,556,1188,134),Color("#191b32"))
	var title := "Salta desde el borde iluminado"
	var line := "ESPACIO o ↑   Saltar. David corre solo."
	match phase:
		Phase.BRIEFING:
			title = "Inés, por radio"
			line = "El puente se deshizo. Salta entre las losas. Mi farol marca la mitad.   ·   ESPACIO para correr"
		Phase.FALLEN:
			title = "El vacío te alcanzó"
			line = "ESPACIO   Reintentar desde el farol" if beacon_lit else "ESPACIO   Reintentar desde la entrada"
		Phase.ARRIVED:
			title = "Mara: «¡Veo tu luz sobre la rejilla!»"
			line = "Has cruzado el vacío.   ·   ESPACIO   Bajar a la esclusa del estuario"
	caption(74,605,title,27,PAPER)
	caption(74,652,line,21,EDGE)

func jump_markers(edge: float) -> void:
	var launch := SCREEN_X + edge - distance - 40.0
	if launch < -300 or launch > 1320:
		return
	var gold := Color("#ffd785")
	var speed := 360.0 if edge > BEACON else 320.0
	var airtime := 2.0 * 685.0 / 1800.0
	# Las tres muescas están talladas en el canto de la losa de salida.
	draw_line(Vector2(launch-18,BASE_Y),Vector2(launch+18,BASE_Y),gold,6,true)
	for i in 3:
		var x := launch - 14.0 + i * 12.0
		draw_polyline(PackedVector2Array([Vector2(x,BASE_Y+5),Vector2(x+6,BASE_Y+11),Vector2(x,BASE_Y+17)]),gold,3,true)
	# Las chispas siguen el arco del salto hasta el reflector de la otra losa.
	for i in range(1, 10):
		var time := airtime * i / 10.0
		var pos := Vector2(launch + speed*time, BASE_Y - (685.0*time - 900.0*time*time))
		var radius := 4.0 if i % 2 else 2.5
		draw_circle(pos,radius+4.0,Color(gold,0.12))
		draw_circle(pos,radius,gold)
	var landing := launch + speed*airtime
	draw_line(Vector2(landing-14,BASE_Y),Vector2(landing+14,BASE_Y),gold,4)
	draw_arc(Vector2(landing,BASE_Y),10,PI,TAU,14,gold,3,true)
