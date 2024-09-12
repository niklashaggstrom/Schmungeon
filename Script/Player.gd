extends Area2D

const direction_indicator_offset_value_ok : int = 32
const direction_indicator_offset_value_notok : int = 16

@onready var ray = $RayCast2D
@onready var direction_indicator = $DirectionIndicator

var tile_layer : CanvasLayer

var selected_direction = Vector2.ZERO
var selected_direction_ok = false
var selected_placement_ok = false
var last_moved_from = Constants.movement_rule_directions.NONE

var turn_step : Constants.TurnSteps

var current_tile
var target_tile

var character = Character.new("Kurt Röfmügel", 20, 12)

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_layer = get_tree().get_current_scene().get_node("TileLayer")
	position = Vector2.ZERO
	position += Vector2.ONE * Constants.tile_size/2
	direction_indicator.visible = false
	self.area_entered.connect(self._on_area_entered)
	var start_tile = _pick_tile(position, Constants.movement_rule_directions.NONE)
	start_tile.state = Tile.TileState.PLACED
	turn_step = Constants.TurnSteps.PICK_DIRECTION

func _on_area_entered(area): 
	current_tile = area

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called when an InputEvent hasn't been consumed by _input 
# or any GUI Control item. 
func _unhandled_input(event):
	if(turn_step == Constants.TurnSteps.PICK_DIRECTION) : 
		if (selected_direction_ok 
			and event.is_action_pressed("accept")):
			_accept_direction()
		elif event.is_action_pressed("up"):
			_indicate_direction(Vector2.UP)
		elif event.is_action_pressed("right"):
			_indicate_direction(Vector2.RIGHT)
		elif event.is_action_pressed("down"):
			_indicate_direction(Vector2.DOWN)
		elif event.is_action_pressed("left"):
			_indicate_direction(Vector2.LEFT)
		elif (!selected_direction_ok 
			and (event.is_action_released("up") 
				or event.is_action_released("right") 
				or event.is_action_released("down") 
				or event.is_action_released("left"))):
			_clear_direction()

func _clear_direction() -> void:
	direction_indicator.visible = false
	selected_direction = Vector2.ZERO
	selected_direction_ok = false
	target_tile = null 

func _indicate_direction(direction) -> void:
	var direction_indicator_offset
	var frame_cords_x
	var frame_cords_y
	
	ray.target_position = direction * Constants.tile_size
	ray.force_raycast_update()
	target_tile = ray.get_collider()
	
	selected_direction_ok = _check_move_ok(direction)
	if selected_direction_ok:
		selected_direction = direction
		direction_indicator_offset = direction_indicator_offset_value_ok
		frame_cords_y = 0
	else: 
		selected_direction = Vector2.ZERO
		direction_indicator_offset = direction_indicator_offset_value_notok
		frame_cords_y = 1
	
	match direction:
		Vector2.UP:
			frame_cords_x = 0
		Vector2.RIGHT:
			frame_cords_x = 1
		Vector2.DOWN:
			frame_cords_x = 2
		Vector2.LEFT:
			frame_cords_x = 3
	
	direction_indicator.frame_coords = Vector2(frame_cords_x, frame_cords_y)
	direction_indicator.offset = direction * direction_indicator_offset
	
	if(!direction_indicator.visible):
		direction_indicator.visible = true

func _check_move_ok(direction) -> bool:
	var movement = Helpers.vector2_to_movement_rule_directions(direction)
	var fromCurrentOk = current_tile.check_exit_is_ok(last_moved_from, movement)
	var next_entrypoint = Helpers.invert_movement_rule_directions(movement)
	var toNextOk = true
	if(target_tile != null):
		toNextOk = target_tile.check_entry_is_ok(next_entrypoint)
	return fromCurrentOk and toNextOk

func _accept_direction() -> void : 
	var target_position = current_tile.position + selected_direction * Constants.tile_size
	var movement = Helpers.vector2_to_movement_rule_directions(selected_direction)
	var entrypoint = Helpers.invert_movement_rule_directions(movement)
	
	if(target_tile == null) : 
		target_tile = _pick_tile(target_position, entrypoint)
		turn_step = Constants.TurnSteps.PLACE_TILE
		await target_tile.is_placed
	
	turn_step = Constants.TurnSteps.MOVE
	_move_to_tile(target_tile)

func _pick_tile(target_position : Vector2, entrypoint : Constants.movement_rule_directions) -> Tile : 
	var tile_info : TileInfo = TileStack.pick_tile()
	var tile : Tile = Tile.new(tile_info, target_position, entrypoint, tile_layer)
	tile.state = Tile.TileState.PICKED
	return tile
	

func _move_to_tile(tile : Tile) -> void:
	position = tile.position
	last_moved_from = Helpers.invert_movement_rule_directions(
						Helpers.vector2_to_movement_rule_directions(selected_direction))
	_clear_direction()
	turn_step = Constants.TurnSteps.PICK_DIRECTION
	


