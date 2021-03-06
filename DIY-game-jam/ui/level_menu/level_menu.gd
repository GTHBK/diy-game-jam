extends CanvasLayer
class_name LevelMenu


var level setget set_level
var init_text = 0
onready var btn_spawn: Button = $ViewportContainer/Panel/VBoxContainer/LevelInfo/Waves/Spawn
onready var wave_label: Label = $ViewportContainer/Panel/VBoxContainer/LevelInfo/Waves/Label
onready var hp_label: Label = $ViewportContainer/Panel/VBoxContainer/LevelInfo/PlayerStatus/HPValue
onready var mana_label: Label = $ViewportContainer/Panel/VBoxContainer/LevelInfo/PlayerStatus/ManaValue
onready var speed_btn: Button = $ViewportContainer/Panel/VBoxContainer/SpeedMode/SpeedBtn
onready var slot_btn: Button = $ViewportContainer/Panel/VBoxContainer/remove_defender/SlotBtn
onready var setting_panel: Panel = $ViewportContainer/SettingPanel
onready var bgPanel: Panel = $ViewportContainer/SettingPanel/bgPanel
onready var waveText: Label = $ViewportContainer/waveText
onready var tween = $ViewportContainer/waveText/Tween
onready var result = $ViewportContainer/result
onready var bossPanel = $ViewportContainer/bossPanel
onready var volume_slider = $ViewportContainer/SettingPanel/VBoxContainer/HBoxContainer2/HSlider

var speed_arr = [0.5, 1, 1.5, 2]
var speed_arr_idx = 1

func set_level(curr_level):
	level = curr_level
	volume_slider.value = Sound.soundplayer.volume_db
	setup_spawn_buttons()
	register_event_listener()
	setup_hp_label()
	setup_mana_label()


func setup_spawn_buttons():
	# Just for test
	var previews = get_tree().get_nodes_in_group("defender_preview")
	for preview in previews:
		(preview as DefenderPreview).defender_data = null
	var defenders = GameSaveManager.current_save.defenders
	assert(len(defenders) <= len(previews))
	var preview_id = 0
	for id in defenders:
		var defender: DefenderData = GameSaveManager.defenders[id]
		var preview: DefenderPreview = previews[preview_id]
		preview.defender_data = defender
		preview_id += 1


func register_event_listener():
	assert(btn_spawn.connect("pressed", level, "spawn_next_wave") == OK)
	assert(level.connect("wave_changed", self, "update_wave_label") == OK)
	assert(level.connect("next_wave_availability_changed", self, "_on_next_wave_availability_changed") == OK)
	assert(level.connect("show_result_signal", self, "show_result") == OK)
	assert(Player.connect("show_result_signal", self, "show_result") == OK)
	assert(level.connect("show_boss", self, "show_boss_ui") == OK)

func update_wave_label(curr_idx: int, wave_cnt: int):
	wave_label.text = "%d / %d" % [curr_idx, wave_cnt]
	
	# show the wave info
	if init_text:
		waveText.show()
		if curr_idx == wave_cnt:
			waveText.text = "Boss wave is comming!"
		else:
			waveText.text = "Enemy wave %3d  is comming!" % [curr_idx]
		var start_color = Color(1.0, 1.0, 1.0, 1.0)
		var end_color = Color(1.0, 1.0, 1.0, 0.0)
		tween.interpolate_property(waveText, "modulate", start_color, end_color, 3)
		tween.start()
	else: init_text = 1


func _on_next_wave_availability_changed(is_avaliable: bool):
	btn_spawn.disabled = not is_avaliable


func setup_hp_label():
	update_hp_label(Player.hp)
	for end in get_tree().get_nodes_in_group("end"):
		end = end as End
		assert(end.connect("attacker_reached", self, "_on_attacker_reached") == OK)


func _on_attacker_reached(_attacker):
	update_hp_label(Player.hp)


func update_hp_label(hp: int):
	hp_label.text = String(hp)
	

func setup_mana_label():
	update_mana_label(Player.mana)
	assert(Player.connect("mana_changed", self, "update_mana_label") == OK)


func update_mana_label(mana: int):
	mana_label.text = String(mana)

func speed_btn_onPressed():
	speed_arr_idx += 1
	speed_arr_idx %= 4
	Player.speed_mode = speed_arr[speed_arr_idx]
	speed_btn.text = "Speed : " + str(Player.speed_mode*100) + "%"


func _on_OpenMenu_pressed():
	setting_panel.show()
	Player.atkPause = true
	Player.defPause = true

func _on_continue_pressed():
	setting_panel.hide()
	Player.atkPause = false
	Player.defPause = false


func _on_menu_pressed():
	Player.can_win = false
	Game.change_scene("opening", "level_select")
	Sound.play_sound("opening")


func show_result():
	result.show()
	
func show_boss_ui(racial):
	bossPanel.show_boss(racial)


func _on_HSlider_value_changed(value):
	print(Sound.soundplayer.volume_db)
	Sound.soundplayer.volume_db = value
	var save: GameSave = GameSaveManager.current_save
	save.volume = value
	GameSaveManager.save()


func _on_SlotBtn_pressed():
	if Player.remove_defender_mode:
		Player.remove_defender_mode = false
		slot_btn.text = "remove mode: off"
	else:
		Player.remove_defender_mode = true
		slot_btn.text = "remove mode: on"
	
