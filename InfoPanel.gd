extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	$InfoContainer/TileStackSizeLabel.text = "Tiles left: " + str(TileStack.get_stack_size())
	TileStack.tile_picked.connect(self._on_tile_picked)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_tile_picked(_arg_tile) : 
	$InfoContainer/TileStackSizeLabel.text = "Tiles left: " + str(TileStack.get_stack_size())
