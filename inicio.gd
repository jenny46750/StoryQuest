extends Node

const PISO := preload("res://scenes/quests/story_quests/forja_jenny/quest.tres")

func _ready() -> void:
    call_deferred("_abrir_forja")

func _abrir_forja() -> void:
    GameState.set_quest(PISO)
    GameState.quest.challenge_start_scene = PISO.first_scene
    var destino: String = PISO.first_scene
    if OS.has_feature("web") and JavaScriptBridge.get_interface("window").location.hash == "#vacio":
        destino = "res://scenes/quests/story_quests/forja_jenny/episodios/carrera_vacio.tscn"
    GameState.set_scene(destino)
    get_tree().change_scene_to_file(destino)
