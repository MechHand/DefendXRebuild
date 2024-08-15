class_name ShaderApplier extends Sprite2D

@export_file("*.txt") var palette_file : String
@export var shader : ShaderMaterial
const MAX_PALETTE_SIZE : int = 765;

func _ready() -> void:
	shader = material as ShaderMaterial
	_connect_file_dropped()
	
	if palette_file:
		print(palette_file)
		print("Palette file exists : ", FileAccess.file_exists(palette_file))
		var text : String = FileAccess.open("res://Resources/Palettes/calm-48.txt", FileAccess.READ).get_as_text()
		var lines : PackedStringArray = text.split("\n")
		
		print(lines)
		_add_color_to_shader(lines)


func _connect_file_dropped() -> void:
	var root : Window = get_tree().root
	root.files_dropped.connect(_on_file_dropped)


func _add_color_to_shader(lines : PackedStringArray) -> void:
	var color_amount_in_hex_file : int = lines.size() -1;
	var colors : Array[Color]
	
	if color_amount_in_hex_file > MAX_PALETTE_SIZE:
		printerr("Max number of colors in the palette should be ", MAX_PALETTE_SIZE, ", but the file has ", color_amount_in_hex_file, " colors.")
		return
	
	for line in lines:
		if line.is_empty():
			continue
		
		var new_color : Color = Color(line)
		colors.append(new_color)
	
	shader.set_shader_parameter(&"colors", colors)
	shader.set_shader_parameter(&"color_amount", color_amount_in_hex_file)
	show()


func _on_file_dropped(files : Array[String]) -> void:
	print(files, " was dropped.")
	
	if (_is_file_hex(files[0])):
		var text : String = FileAccess.open(files[0], FileAccess.READ).get_as_text()
		var lines : PackedStringArray = text.split("\r\n")
		
		print(lines)
		_add_color_to_shader(lines)


func _is_file_hex(filename : String) -> bool:
	if (filename.get_extension() == "hex"):
		return true
	else:
		return false
