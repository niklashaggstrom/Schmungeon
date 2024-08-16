extends Node

var _stack : Array 
signal tile_picked(tile)

func _ready():
	_initialize_stack()

func _initialize_stack():
	var collection = _get_collection()
	collection.shuffle()
	collection.push_front(TileInfo.new("StartTile", {0:15, 1:15, 2:15, 4:15, 8:15}, Vector2i(2,0)))
	_stack  = collection 

func get_stack_size() -> int :
	return _stack.size()

func pick_tile() -> TileInfo :
	var tile = _stack.pop_front()
	tile_picked.emit (tile)
	return tile

func _get_collection() -> Array : 
	var tile_array :  Array = [ 
		TileInfo.new("1", {1:15, 2:15, 4:15, 8:15}, Vector2i(2,0)),
		TileInfo.new("2", {2:14, 4:14, 8:14}, Vector2i(3,0)),
		TileInfo.new("3", {2:10, 8:10}, Vector2i(4,0)),
		TileInfo.new("4", {1:3, 2:3}, Vector2i(0,1)),
		TileInfo.new("5", {8:8}, Vector2i(1,1)),
		TileInfo.new("6", {1:9, 2:6, 4:6, 8:9 }, Vector2i(2,1))
	]
	return tile_array
	
