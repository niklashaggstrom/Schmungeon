extends Node
class_name TileInfo

var title : String
var movement_rules : Dictionary
var face_frame_coords : Vector2i

func _init(t : String, mr: Dictionary, ffc : Vector2i):
	title = t
	movement_rules = mr
	face_frame_coords = ffc
	
func rotate_rules(rotation_direction : Constants.RotationDirection) -> void:
	var new_rules : Dictionary = {}
	for rule_key in movement_rules.keys(): 
		var new_key
		var new_rule
		match rotation_direction : 
			Constants.RotationDirection.CLOCKWISE :
				new_key = Helpers.shift_movement_rule_directions_cw(rule_key)
				new_rule = Helpers.shift_movement_rule_directions_cw(movement_rules[rule_key])
			Constants.RotationDirection.COUNTER_CLOCKWISE :
				new_key = Helpers.shift_movement_rule_directions_ccw(rule_key)
				new_rule = Helpers.shift_movement_rule_directions_ccw(movement_rules[rule_key])
		new_rules[new_key] = new_rule
	
	movement_rules = new_rules
