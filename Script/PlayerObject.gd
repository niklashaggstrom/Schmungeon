extends Area2D
class_name PlayerObject

const direction_indicator_offset_value_ok : int = 32
const direction_indicator_offset_value_notok : int = 16

var _raycast : RayCast2D
var _direction_indicator : Sprite2D

var tile_layer : CanvasLayer

var selected_direction = Vector2.ZERO
var selected_direction_ok = false
var selected_placement_ok = false
var last_moved_from = Constants.movement_rule_directions.NONE

var turn_step : Constants.TurnSteps

var current_tile
var target_tile

var character : Character
var camera : Camera2D


func _init(playerCharacter : Character, 
			targetPosition : Vector2, 
			parent : Node2D):
	print("init player " + playerCharacter.name)
	character = playerCharacter
	position = targetPosition
	z_index = 100

	add_child(_create_sprite())
	add_child(_create_collider())
	_raycast = _create_raycast()
	add_child(_raycast)
	_direction_indicator = _create_direction_indicator()
	add_child(_direction_indicator)
	camera = _create_camera()
	add_child(camera)
	parent.add_child(self)
	self.area_entered.connect(self._on_area_entered)


func _create_camera() -> Camera2D : 
	var cam = Camera2D.new()
	cam.zoom = Vector2.ONE * 2
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 10
	cam.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER	
	return cam

func _create_raycast() -> RayCast2D : 
	var ray : RayCast2D = RayCast2D.new()
	ray.exclude_parent = true
	ray.target_position = Vector2(0, 48)
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	return ray


func _create_sprite() -> Sprite2D : 
	var sprite : Sprite2D = Sprite2D.new()
	sprite.centered = true
	sprite.name = "PlayerSprite"
	sprite.texture = load("res://player.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.hframes = 1
	sprite.vframes = 1
	sprite.frame_coords = Vector2.ZERO
	return sprite
	
func _create_direction_indicator() -> Sprite2D : 
	var sprite : Sprite2D = Sprite2D.new()
	sprite.visible = false
	sprite.centered = true
	sprite.name = "DirectionIndicator"
	sprite.texture = load("res://icons.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.hframes = 4
	sprite.vframes = 3
	sprite.frame_coords = Vector2(2,0)
	sprite.offset = Vector2(0,16)
	return sprite


func _create_collider() -> CollisionShape2D: 
	var collider : CollisionShape2D = CollisionShape2D.new()
	collider.shape = RectangleShape2D.new()
	collider.shape.size = Vector2.ONE * Constants.player_size
	collider.name = "PlayerCollider"
	return collider

# Called when the node enters the scene tree for the first time.
func _ready():
	print("player ready " + character.name)
	tile_layer = get_tree().get_current_scene().get_node("TileLayer")
	#position = Vector2.ZERO
	#position += Vector2.ONE * Constants.tile_size/2
	#_direction_indicator.visible = false
	#self.area_entered.connect(self._on_area_entered)
	#var start_tile = _pick_tile(position, Constants.movement_rule_directions.NONE)
	#start_tile.state = Tile.TileState.PLACED
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
	_direction_indicator.visible = false
	selected_direction = Vector2.ZERO
	selected_direction_ok = false
	target_tile = null 

func _indicate_direction(direction) -> void:
	var direction_indicator_offset
	var frame_cords_x
	var frame_cords_y
	
	_raycast.target_position = direction * Constants.tile_size
	_raycast.force_raycast_update()
	target_tile = _raycast.get_collider()
	
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
	
	_direction_indicator.frame_coords = Vector2(frame_cords_x, frame_cords_y)
	_direction_indicator.offset = direction * direction_indicator_offset
	
	if(!_direction_indicator.visible):
		_direction_indicator.visible = true

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
	var tile_just_picked = false
	
	if(target_tile == null) : 
		tile_just_picked = true
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
	


