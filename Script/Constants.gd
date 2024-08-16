class_name Constants

const tile_size : int = 48

enum movement_rule_directions {
	NONE = 0,
	UP = 1,
	RIGHT = 2,
	DOWN = 4,
	LEFT = 8
}

enum TurnSteps {
	WAIT = 0,
	PICK_DIRECTION = 1,
	PLACE_TILE = 2,
	MOVE = 3
}

enum RotationDirection {
	CLOCKWISE = 0,
	COUNTER_CLOCKWISE = 1
}
