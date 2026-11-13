extends Node

const PISO := preload("res://scenes/quests/story_quests/forja_jenny/quest.tres")

func _ready() -> void:
    call_deferred("_abrir_forja")

func _abrir_forja() -> void:
    GameState.set_quest(PISO)
    GameState.quest.challenge_start_scene = PISO.first_scene
    GameState.set_scene(PISO.first_scene)
    get_tree().change_scene_to_file(PISO.first_scene)
