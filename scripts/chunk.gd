extends Node3D

const SIZE = 16

@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $StaticBody3D/CollisionShape3D

var blocks = {}
var world
var noise

var dirty := false
var collision_dirty := true


func place_block(local_pos: Vector3i, block_id: int):

    if blocks.has(local_pos):
        return

    blocks[local_pos] = block_id
    collision_dirty = true
    mark_dirty()


func destroy_block(local_pos: Vector3i):

    if !blocks.has(local_pos):
        return

    blocks.erase(local_pos)
    collision_dirty = true
    mark_dirty()


func generate():

    ChunkGenerator.generate(self)


func mark_dirty():

    if dirty:
        return

    dirty = true
    world.queue_chunk_rebuild(self)


func rebuild():

    var mesh = VoxelMesh.build(self)

    mesh_instance.mesh = mesh

    if collision_dirty:

        ChunkCollision.build(
            self,
            mesh
        )

        collision_dirty = false
