@tool
extends Node3D
class_name Ocean

const OCEAN_TILE = preload("res://scenes/ocean/ocean_tile.tscn")
@export var size = 500

func _ready():
	# The grid size is 3x3, so we define the range for x and z
	var grid_size = 3
	var half_grid = int(grid_size / 2)  # To skip the middle tile

	# Loop through the grid to place tiles, skipping the center
	for x in range(grid_size):
		for z in range(grid_size):
		# Skip the middle tile (position (1, 1) in a 3x3 grid)
			if x == half_grid and z == half_grid:
				continue

			var tile_instance = OCEAN_TILE.instantiate()
			tile_instance.position = Vector3((x - half_grid) * size, 0, (z - half_grid) * size)
			add_child(tile_instance)
