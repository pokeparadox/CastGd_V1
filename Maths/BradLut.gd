extends Node

# Lookup table for sin/cos and for their direction vectors using Brads
# We only have to store a subset of values due to mirroring and the reduction from 360 degres to 256 Brads.
# Ported from original C++ in Penjin by PokeParadox

var sin_cos_lookup = {}
var tan_lookup = {}

var Brad = load("Maths/Brad.gd")


func _init():
	for i in range(0, 256):
		var brad = Brad.new()
		brad.brad(i)
		tan_lookup[i] = tan(brad.get_angle_rad())
		if i < 128:
			sin_cos_lookup[i] = sin(brad.get_angle_rad())


func sin_i(a : int) -> float:
	a = wrapi(a,0,255)
	if a > 127:
		a -= 128
		return -sin_cos_lookup[a]
	return sin_cos_lookup[a]


func cos_i(a : int) -> float:
	return sin_i(a + 64)

func tan_i(a : int) -> float:
	return tan_lookup[a]

func sin_b(brad : Brad) -> float:
	return sin_i(brad.get_angle())


func cos_b(brad : Brad) -> float:
	return cos_i(brad.get_angle())

func tan_b(brad : Brad) -> float:
	return tan_i(brad.get_angle())

var brad_to_vector_lookup = {}

func brad_to_vector_2d(brad_angle: Brad) -> Vector2:
	var a : int = brad_angle.get_angle()
	if not brad_to_vector_lookup.has(a):
		brad_to_vector_lookup[a] = Vector2(sin_i(a), -cos_i(a))
	return brad_to_vector_lookup[a]

