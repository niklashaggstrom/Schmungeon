class_name Helpers

static func invert_movement_rule_directions(directions : Constants.movement_rule_directions) -> Constants.movement_rule_directions:
	var ret_val : Constants.movement_rule_directions = Constants.movement_rule_directions.NONE 
	
	if directions & Constants.movement_rule_directions.DOWN:
		ret_val = (ret_val ^ Constants.movement_rule_directions.UP) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.LEFT:
		ret_val = (ret_val ^ Constants.movement_rule_directions.RIGHT) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.UP:
		ret_val = (ret_val ^ Constants.movement_rule_directions.DOWN) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.RIGHT:
		ret_val = (ret_val ^ Constants.movement_rule_directions.LEFT) as Constants.movement_rule_directions 

	return ret_val

static func vector2_to_movement_rule_directions(direction)-> Constants.movement_rule_directions:
	match direction:
		Vector2.UP:
			return Constants.movement_rule_directions.UP
		Vector2.RIGHT:
			return Constants.movement_rule_directions.RIGHT
		Vector2.DOWN:
			return Constants.movement_rule_directions.DOWN
		Vector2.LEFT:
			return Constants.movement_rule_directions.LEFT
		_:
			return Constants.movement_rule_directions.NONE
	

static func shift_movement_rule_directions_cw(directions : Constants.movement_rule_directions) -> Constants.movement_rule_directions:
	var ret_val : Constants.movement_rule_directions = Constants.movement_rule_directions.NONE 
	
	if directions & Constants.movement_rule_directions.DOWN:
		ret_val = (ret_val ^ Constants.movement_rule_directions.LEFT) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.LEFT:
		ret_val = (ret_val ^ Constants.movement_rule_directions.UP) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.UP:
		ret_val = (ret_val ^ Constants.movement_rule_directions.RIGHT) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.RIGHT:
		ret_val = (ret_val ^ Constants.movement_rule_directions.DOWN) as Constants.movement_rule_directions 

	return ret_val


static func shift_movement_rule_directions_ccw(directions : Constants.movement_rule_directions) -> Constants.movement_rule_directions:
	var ret_val : Constants.movement_rule_directions = Constants.movement_rule_directions.NONE 
	
	if directions & Constants.movement_rule_directions.DOWN:
		ret_val = (ret_val ^ Constants.movement_rule_directions.RIGHT) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.LEFT:
		ret_val = (ret_val ^ Constants.movement_rule_directions.DOWN) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.UP:
		ret_val = (ret_val ^ Constants.movement_rule_directions.LEFT) as Constants.movement_rule_directions 
	if directions & Constants.movement_rule_directions.RIGHT:
		ret_val = (ret_val ^ Constants.movement_rule_directions.UP) as Constants.movement_rule_directions 

	return ret_val
