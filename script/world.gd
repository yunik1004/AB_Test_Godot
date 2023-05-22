extends Node

# Nodes
var sprite_l
var sprite_r
var button_next
var text_title
var text_status
var text_answer = {"L": null, "R": null}

# Hyperparameter
var width_default = 400
var height_default = 400

# Status
var correct_pos

# Others
var rng = RandomNumberGenerator.new()
var reader = ZIPReader.new()
var resources = {}
var resources_idx_list
var imgs = {"L": Image.new(), "R": Image.new()}
var textures = {"L": ImageTexture.new(), "R": ImageTexture.new()}

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_l = $LeftImage
	sprite_r = $RightImage
	button_next = get_node("GUI/NextButton")
	text_title = get_node("GUI/Title")
	text_status = get_node("GUI/Status")
	text_answer["L"] = get_node("GUI/Answer_L")
	text_answer["R"] = get_node("GUI/Answer_R")
	
	# Set signal
	sprite_l.connect("click_signal", img_clicked.bind("L"))
	sprite_r.connect("click_signal", img_clicked.bind("R"))
	button_next.connect("pressed", btn_pressed)
	
	# Set visibility
	button_next.visible = false
	for pos in text_answer:
		text_answer[pos].visible = false
	
	# Use ZipReader to read zip file
	var err = reader.open(Global.file_path)
	if err != OK:
		push_error("No such file exists")
		
	var f_idx = null
	var f_class = null
	var f_class_enum = null
	for path in reader.get_files():
		if f_idx == null or not path.begins_with(f_idx):
			f_idx = path
			resources[f_idx] = {"correct": [], "wrong": []}
		elif f_class == null or not path.begins_with(f_class):
			f_class = path
			if path.ends_with("correct/") or path.ends_with("correct\\"):
				f_class_enum = "correct"
			else:
				f_class_enum = "wrong"
		else:
			resources[f_idx][f_class_enum].append(path)
			
	resources_idx_list = resources.keys()
	resources_idx_list.shuffle()
	
	# Parse total round
	Global.total_round = len(resources)
	
	#var res = reader.read_file("1/correct/000000_0.png")
	
	update_img()
	
	
func update_img():
	Global.current_round += 1
	if Global.current_round > Global.total_round:
		get_tree().change_scene_to_file("res://scene/result.tscn")
		return
		
	var current_idx = resources_idx_list[Global.current_round - 1]
		
	text_title.text = "A/B Test (Round %d/%d)" % [Global.current_round, Global.total_round]
	
	var texture_path = {
		"Correct": resources[current_idx]["correct"][rng.randi() % resources[current_idx]["correct"].size()],
		"Wrong": resources[current_idx]["wrong"][rng.randi() % resources[current_idx]["wrong"].size()],
	}
	
	var texture_l_path
	var texture_r_path
	
	var rnd = rng.randi_range(0, 1)
	if rnd == 0:
		texture_l_path = texture_path["Correct"]
		texture_r_path = texture_path["Wrong"]
		correct_pos = "L"
	else:
		texture_l_path = texture_path["Wrong"]
		texture_r_path = texture_path["Correct"]
		correct_pos = "R"
		
	imgs["L"].load_png_from_buffer(reader.read_file(texture_l_path))
	imgs["R"].load_png_from_buffer(reader.read_file(texture_r_path))
	
	# Resize the images
	var width_img = imgs["L"].get_width()
	var height_img = imgs["L"].get_height()
	
	var width_final
	var height_final
	if width_img >= height_img:
		width_final = width_default
		height_final = int(height_img * height_default / width_img)
	else:
		height_final = height_default
		width_final = int(width_img * width_default / height_img)

	imgs["L"].resize(width_final, height_final)
	imgs["R"].resize(width_final, height_final)
	
	textures["L"].set_image(imgs["L"])
	textures["R"].set_image(imgs["R"])
	
	sprite_l.texture = textures["L"]
	sprite_r.texture = textures["R"]
	
	
func img_clicked(img_pos):
	if not button_next.visible:
		button_next.visible = true
		text_answer[correct_pos].visible = true
		
		if correct_pos == img_pos:
			Global.num_correct += 1
			text_answer[correct_pos].modulate = Color(0, 1, 0, 1)
		else:
			text_answer[correct_pos].modulate = Color(1, 0, 0, 1)
			
		text_status.text = "Correct / Wrong : %d / %d" % [Global.num_correct, Global.current_round - Global.num_correct]

func btn_pressed():
	button_next.visible = false
	for pos in text_answer:
		text_answer[pos].visible = false
	update_img()
