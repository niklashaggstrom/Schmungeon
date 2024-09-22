extends Node


signal character_damage_taken(character, amount)
signal character_died(character)

var _start_position = Vector2.ZERO
var _players : Array 

func _ready():
	_place_start_tile()
	_initialize_players()
	_start_game()

func _initialize_players() :
	var char1 =  Character.new("Smögert Hävert", 20, 12)
	
	
	#var position = Vector2.ZERO
	#position += Vector2.ONE * Constants.tile_size/2
	var scene = get_tree().get_current_scene()
	var player1 = PlayerObject.new(char1, _start_position, scene)
	player1.camera.make_current()

func _place_start_tile() : 
	var start_tile = _pick_tile(_start_position, Constants.movement_rule_directions.NONE)
	start_tile.state = Tile.TileState.PLACED

func _pick_tile(target_position : Vector2, entrypoint : Constants.movement_rule_directions) -> Tile : 
	var tile_info : TileInfo = TileStack.pick_tile()
	var tile_layer = get_tree().get_current_scene().get_node("TileLayer")

	var tile : Tile = Tile.new(tile_info, target_position, entrypoint, tile_layer)
	tile.state = Tile.TileState.PICKED
	return tile

func _start_game() :
	pass


func handle_player_done() : 
	pass

func handle_player_state_changed() : 
	pass

