extends Node3D

@export var max_angle : float = 30
@export var light_colors : PackedColorArray = [Color.RED,Color.GREEN,Color.ORANGE]
@export var max_range : float = 100
@export var charge_speed : float = 0.25
@export var attack_length : float = 1

@onready var agent : NavAgent = $".."
@onready var pivot : Node3D = get_child(0).get_child(0)

var target : Node3D
var los : bool = false
var charge : float = 0
var lights : Array[SpotLight3D]
var in_range : bool = false
var timer : float = 0


func _ready():
	for light in pivot.get_children():
		if light is SpotLight3D: lights.append(light)

func _process(delta):
	target = agent._target_node
	watch()
	if charge >= 1:
		attack(delta)
	else :
		charging(delta)


func watch() -> void :
	var dir : Vector3 = target.global_position.direction_to(global_position)
	if dir.dot(-get_child(0).global_basis.z) > sin(deg_to_rad(max_angle)):
		pivot.look_at(target.global_position,Vector3.UP,true)
		var dist: float = global_position.distance_to(target.global_position)
		in_range = true if dist < max_range else false
		los = true
	else:
		los = false
		in_range = false

func attack(delta : float) -> void :
	set_light_color(0)
	timer += delta
	if timer >= 1 :
		charge = 0

func charging(delta : float) -> void :
	if los and charge<1 and in_range:
		charge += delta*charge_speed
		set_light_color(2)
	elif charge>0 and not los:
		charge -= delta*charge_speed
		set_light_color(1)

func set_light_color(i : int)-> void :
	for light in lights:
		light.light_color = light_colors[i]
	pivot.get_child(0).set_instance_shader_parameter("lights",i)
