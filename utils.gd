extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_push_vector(root:Node2D,delta:float,rot_speed:float=2)->void:
	var areas:=[]
	var soft_collision := root.get_node("%soft_collision")
	var push_vector = Vector2.ZERO
	if soft_collision.has_overlapping_areas():
		areas = soft_collision.get_overlapping_areas()
		if areas.size()>0:
			var area = areas[0]
			push_vector = area.global_position.direction_to(soft_collision.global_position)
	root.velocity = push_vector *delta
	root.rotation = lerp_angle(root.rotation, (root.velocity*delta).angle(),delta*rot_speed)
	# root.global_position += root.velocity
	root.move_and_slide()

