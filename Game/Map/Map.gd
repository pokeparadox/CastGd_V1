tool
extends Node2D

var RayInfo = load("Game/Caster/RayInfo.gd")

var map_dims := Vector2(8, 8)
export var block_size : int = 64
var map_data := [
 1,1,1,1,1,1,1,1,
 1,0,1,0,0,0,0,1,
 1,0,1,0,0,0,0,1,
 1,0,1,0,0,0,0,1,
 1,0,0,0,0,0,0,1,
 1,0,0,0,0,1,0,1,
 1,0,0,0,0,0,0,1,
 1,1,1,1,1,1,1,1,
]

var player_rays = {}

func get_map_value(index : int) -> int:
	if map_data.size() > index:
		return map_data[index]
	return -1


func draw_map() -> void:
	var c := Color.white
	for y in range(map_dims.y):
		for x in range(map_dims.x):
			if map_data[(y * map_dims.x) + x] == 1:
				c = Color.white
			else:
				c = Color.black
			
			draw_rect(Rect2(Vector2((x * block_size) + 1, (y * block_size) + 1), Vector2(block_size - 1, block_size - 1)), c, true, 1)


func draw_player_rays() -> void:
	if player_rays != null:
		for i in range (0, player_rays.size()):
			var info : RayInfo = player_rays[i]
			draw_line(info.start_position, info.end_position, info.colour, 2)


func _draw():
	draw_map()
	draw_player_rays()


# Called when the node enters the scene tree for the first time.
func _ready():
	update()


func _on_Screen_player_ray(start_pos, end_pos, colour, ray_count):
	var info : RayInfo = RayInfo.new()
	info.start_position = start_pos
	info.end_position = end_pos
	info.colour = colour
	if player_rays.size() > 0 and player_rays.has(ray_count):
		player_rays[ray_count].queue_free()
	
	player_rays[ray_count] = info
	update()
