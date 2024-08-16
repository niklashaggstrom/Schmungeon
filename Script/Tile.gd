class_name Tile
extends Area2D

const empty_face = Vector2i.ZERO
const back_face = Vector2i(1,0)

var tile_info : TileInfo 
var _initial_entrypoint : Constants.movement_rule_directions
var _selected_rotation_ok : bool

enum TileState {
	IN_STACK = 0,
	PICKED = 1,
	PLACED = 2 
}

var state : TileState = TileState.IN_STACK : 
	get : 
		return state
	set (value) : 
		state = value
		state_changed.emit(self, value)

signal state_changed(tile, new_state)
signal is_picked
signal is_placed

func _init(tileInfo : TileInfo, 
			targetPosition : Vector2, 
			initialEntrypoint : Constants.movement_rule_directions, 
			parent : CanvasLayer):
	tile_info = tileInfo
	position = targetPosition
	_initial_entrypoint = initialEntrypoint
	self.state_changed.connect(self._on_state_changed)

	add_child(_create_tile_face())
	add_child(_create_collider())
	
	state = TileState.IN_STACK
	parent.add_child(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Called when an InputEvent hasn't been consumed by _input 
# or any GUI Control item. 
func _unhandled_input(event):
	if(state == TileState.PICKED) :
		if event.is_action_pressed("right"):
			_rotate_tile(Constants.RotationDirection.CLOCKWISE)
		elif event.is_action_pressed("left"):
			_rotate_tile(Constants.RotationDirection.COUNTER_CLOCKWISE)
		elif (_selected_rotation_ok 
				and event.is_action_pressed("accept")):
			_accept_rotation()

func _rotate_tile(rotation_direction : Constants.RotationDirection) -> void: 
	match rotation_direction : 
		Constants.RotationDirection.CLOCKWISE :
			rotate(deg_to_rad(90))
		Constants.RotationDirection.COUNTER_CLOCKWISE :
			rotate(deg_to_rad(-90))
	tile_info.rotate_rules(rotation_direction)
	_check_rotation_ok()

func _check_rotation_ok() -> void:
	_selected_rotation_ok = check_entry_is_ok(_initial_entrypoint)
	if _selected_rotation_ok:
		$TileFace.self_modulate = Color(0.5, 1, 0.5, 1)
	else: 
		$TileFace.self_modulate = Color(1, 0.5, 0.5, 1)

func _accept_rotation() -> void : 
	state = Tile.TileState.PLACED

func _create_tile_face() -> Sprite2D : 
	var tile_face : Sprite2D = Sprite2D.new()
	tile_face.centered = true
	tile_face.name = "TileFace"
	tile_face.texture = load("res://Tiles.png")
	tile_face.hframes = 10
	tile_face.vframes = 10
	tile_face.frame_coords = tile_info.face_frame_coords
	return tile_face

func _create_collider() -> CollisionShape2D: 
	var tile_collider : CollisionShape2D = CollisionShape2D.new()
	tile_collider.shape = RectangleShape2D.new()
	tile_collider.shape.size = Vector2.ONE * Constants.tile_size
	tile_collider.name = "TileCollider"
	return tile_collider
	
func _on_state_changed(_sender, new_state) -> void : 
	match new_state:
		TileState.IN_STACK:
			$TileFace.frame_coords = tile_info.face_frame_coords
			$TileFace.self_modulate = Color(0.5, 1, 0.5, 1)
		TileState.PICKED:
			$TileFace.frame_coords = tile_info.face_frame_coords
			_check_rotation_ok()
			self.is_picked.emit()
		TileState.PLACED:
			$TileFace.frame_coords = tile_info.face_frame_coords
			$TileFace.self_modulate = Color(1, 1, 1, 1)
			self.is_placed.emit()

func check_exit_is_ok(entrypoint : Constants.movement_rule_directions, 
				exit_direction : Constants.movement_rule_directions
			) -> bool : 
	var retVal: bool = false
	if(tile_info.movement_rules.has(entrypoint)):
		var applicable_rule = tile_info.movement_rules[entrypoint] as Constants.movement_rule_directions
		retVal = applicable_rule & exit_direction
	return retVal

func check_entry_is_ok(entrypoint : Constants.movement_rule_directions) -> bool :
	var retVal: bool = true
	if(!tile_info.movement_rules.has(entrypoint)):
		retVal = false
	return retVal
