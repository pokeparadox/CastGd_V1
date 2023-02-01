extends Node2D

signal player_ray(start_pos, end_pos, colour, ray_count)

const LIMIT : float = 0.0001
const MAX_DEPTH : int = 8
const FIELD_OF_VISION : int = 60
const SCREEN_HEIGHT : int = 320
var half_screen_height : int = SCREEN_HEIGHT * 0.5
const SCREEN_WIDTH : int = 480


var MAP_BLOCK_SIZE : int
var MAP_WIDTH : int
var MAP_HEIGHT : int

func _ready():
	 MAP_BLOCK_SIZE = get_node("../Map").block_size
	 MAP_WIDTH = get_node("../Map").map_dims.x
	 MAP_HEIGHT = get_node("../Map").map_dims.y


func update_screen() -> void:
	update()


func fix_angle(a : int) -> int:
	return wrapi(a, 0, 359)

func get_map_value_vec(pos : Vector2) -> int:
	return get_map_value_x_y(int(pos.x), int(pos.y))

func get_map_value_x_y(x : int, y : int) -> int:
	return get_map_value(y * MAP_WIDTH + x)


func get_map_value(index : int) -> int:
	if get_node("../Map").map_data.size() > index and index > 0:
		return get_node("../Map").map_data[index]
	return -1


func _draw() -> void:
	draw_background()
	draw_rays_2d()


func draw_background() -> void:
	draw_rect(Rect2(Vector2(0, 0), Vector2(SCREEN_WIDTH, half_screen_height)), Color8(0, 255, 255))
	draw_rect(Rect2(Vector2(0, half_screen_height), Vector2(SCREEN_WIDTH, half_screen_height)), Color8(0,0,255))


func draw_rays_2d() -> void:
	var colour : Color
	var map_position := Vector2(0, 0)
	var ray_depth : int
	var vx : float
	var vy : float
	var ray_position : Vector2
	var ray_angle : float
	var offset : Vector2 = Vector2.ZERO
	var dis_v : float
	var dis_h : float
	var player_angle : int = 360 - get_node("../Player").heading.get_angle_deg() + 90
	var player_position : Vector2 = get_node("../Player").position
	ray_angle = fix_angle(player_angle + 30)
	
	
	var ray_scaler : int = int(SCREEN_WIDTH / float(FIELD_OF_VISION))
	for r in range(FIELD_OF_VISION):
		# Vertical
		ray_depth = 0
		dis_v = INF
		var tan_v : float = tan(deg2rad(ray_angle))
		var cos_v : float = cos(deg2rad(ray_angle))
		var sin_v : float = sin(deg2rad(ray_angle))
		if cos_v > 0.001:
			# Looking left
			ray_position.x = ((int(player_position.x) >> 6) << 6) + MAP_BLOCK_SIZE
			ray_position.y = (player_position.x - ray_position.x) * tan_v + player_position.y
			offset.x = MAP_BLOCK_SIZE
			offset.y = -offset.x * tan_v
		elif cos_v < -0.001:
			# Looking right
			ray_position.x = (int(player_position.x) >> 6 << 6) - 0.0001
			ray_position.y = (player_position.x - ray_position.x) * tan_v + player_position.y
			offset.x = -MAP_BLOCK_SIZE
			offset.y = -offset.x * tan_v
		else:
			ray_position = player_position
			ray_depth = MAX_DEPTH
		
		while ray_depth < MAX_DEPTH:
			map_position.x = ray_position.x / MAP_BLOCK_SIZE
			map_position.y = ray_position.y / MAP_BLOCK_SIZE
			var map_tile_val : int = get_map_value_vec(map_position)
			if map_tile_val > 0:
				# hit
				ray_depth = MAX_DEPTH
				dis_v = cos_v * (ray_position.x - player_position.x) - sin_v * (ray_position.y - player_position.y)
			else:
				# Next H block
				ray_position += offset
				ray_depth += 1
		
		vx = ray_position.x
		vy = ray_position.y
		
		# Horizontal checking
		ray_depth = 0
		dis_h = INF
		if tan_v != 0:
			tan_v = 1.0 / tan_v
		
		if sin_v > 0.001:
			# looking up
			ray_position.y = ((int(player_position.y) >> 6) << 6) - 0.0001
			ray_position.x = (player_position.y - ray_position.y) * tan_v + player_position.x
			offset.y = -MAP_BLOCK_SIZE
			offset.x = - offset.y * tan_v
		elif sin_v < -0.001:
			#looking down
			ray_position.y = ((int(player_position.y) >> 6) << 6) + MAP_BLOCK_SIZE
			ray_position.x = (player_position.y - ray_position.y) * tan_v + player_position.x
			offset.y = MAP_BLOCK_SIZE
			offset.x = - offset.y * tan_v
		else:
			ray_position = player_position
			ray_depth = MAX_DEPTH
		
		while ray_depth < MAX_DEPTH:
			map_position = ray_position / MAP_BLOCK_SIZE
			var map_tile_val : int = get_map_value_vec(map_position)
			if map_tile_val > 0:
				# hit
				ray_depth = 8
				dis_h = cos_v * (ray_position.x - player_position.x) - sin_v * (ray_position.y - player_position.y)
			else:
				ray_position += offset
				ray_depth += 1
		
		colour = Color8(0, 0.8 * 255, 0)
		if dis_v < dis_h:
			ray_position.x = vx
			ray_position.y = vy
			dis_h = dis_v
			colour = Color8(0, 0.6 * 255, 0)
		
		# Let the map know how to draw the current players ray
		emit_signal("player_ray", player_position, ray_position, colour, r)
		
		var ca : float = fix_angle(player_angle - int(ray_angle))
		dis_h = dis_h * cos(deg2rad(ca))
		var line_h : int = int((MAP_BLOCK_SIZE * SCREEN_HEIGHT)/float(dis_h))
		if line_h > SCREEN_HEIGHT:
			line_h = SCREEN_HEIGHT
		var line_off : int = half_screen_height - (line_h >> 1)
		draw_line(Vector2(4 + (r * ray_scaler), line_off), Vector2(4 + (r * ray_scaler), line_off + line_h), colour, ray_scaler)
		ray_angle = fix_angle(int(ray_angle) - 1)  

