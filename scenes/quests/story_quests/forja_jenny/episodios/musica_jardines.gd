extends Node

@onready var music: BackgroundMusic = $"../BackgroundMusic"
@onready var guards := get_tree().get_nodes_in_group("guard_enemy")
var suspense := 0.0

func _physics_process(delta: float) -> void:
	suspense = maxf(0, suspense - delta)
	for guard: Guard in guards:
		if guard.state in [Guard.State.DETECTING, Guard.State.ALERTED, Guard.State.INVESTIGATING]:
			suspense = 1.5
	var cue := &"batalla" if suspense > 0 else &"calma"
	if music.clip != cue:
		music.set_clip(cue)
