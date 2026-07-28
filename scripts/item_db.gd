class_name ItemDB

enum Block {
	AIR = 0,
	DIRT = 1,
	STONE = 2,
	GRASS = 3
}

const NAMES = {
	Block.DIRT: "Dirt",
	Block.STONE: "Stone",
	Block.GRASS: "Grass"
}

const BLOCK_TEXTURES = {
	Block.DIRT: {
		"all": Vector2i(0, 0)
	},

	Block.STONE: {
		"all": Vector2i(1, 0)
	},

	Block.GRASS: {
		"top": Vector2i(2, 0),
		"side": Vector2i(3, 0),
		"bottom": Vector2i(0, 0)
	}
}
