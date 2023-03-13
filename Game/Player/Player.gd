extends Node2D

signal player_moved

# Support Binary Radians
var Brad = load("Maths/Brad.gd")

# Declare member variables here. Examples:
var direction_vector : Vector2 = Vector2(0.0, 1.0)
var heading : Brad 
var block_size : int
var map_dims : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():	
	position = Vector2(150, 400)
	heading = Brad.new()
	heading.set_angle_deg(90)
	direction_vector = Vector2(1.0, 0.0)
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var i := Input
	var dir_vec := Vector2(0, 0)
	if i.is_action_pressed("ui_left"):
		dir_vec.x = -1
	elif i.is_action_pressed("ui_right"):
		dir_vec.x = 1
	
	if i.is_action_pressed("ui_up"):
		dir_vec.y = 1
	elif i.is_action_pressed("ui_down"):
		dir_vec.y = -1
	
	if dir_vec.length_squared() != 0:
		heading.add_angle(dir_vec.x * delta * 100)
		direction_vector = BradLut.brad_to_vector_2d(heading)
		position = position + (direction_vector * delta * 100 * dir_vec.y)
		emit_signal("player_moved")
		queue_redraw()

func _draw():
	draw_line(Vector2(0,0),direction_vector * 20,Color.YELLOW,4)
