extends CharacterBody3D

@export var speed := 6.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.002

const GRAVITY = 9.8

@onready var camera_pivot = $CameraPivot

@onready var ray = $CameraPivot/Camera3D/RayCast3D
@onready var world = get_node("/root/Main/World")
var inventory := Inventory.new()

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    inventory.add_item(ItemDB.Block.DIRT, 64)

func _unhandled_input(event):
    
    if event.is_action_pressed("slot_1"):
        inventory.selected_slot = 0

    if event.is_action_pressed("slot_2"):
        inventory.selected_slot = 1
        
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            inventory.selected_slot = (inventory.selected_slot + 8) % 9

        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            inventory.selected_slot = (inventory.selected_slot + 1) % 9
    
    if event is InputEventMouseButton and event.pressed:
        if ray.is_colliding():

            var point = ray.get_collision_point()
            var normal = ray.get_collision_normal()

            if event.button_index == MOUSE_BUTTON_LEFT:
                var destroy_pos = Vector3i((point - normal * 0.5).floor())

                var block_id = world.destroy_block(destroy_pos)

                if block_id != ItemDB.Block.AIR:
                    inventory.add_item(block_id, 1)

            elif event.button_index == MOUSE_BUTTON_RIGHT:
                var place_pos = Vector3i((point + normal * 0.5).floor())

                var slot = inventory.get_selected()

                if slot != null:
                    world.place_block(place_pos, slot.id)
                    inventory.remove_selected(1)
    
    if Input.is_action_just_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    if event is InputEventMouseButton:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)

        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(
            camera_pivot.rotation.x,
            deg_to_rad(-89),
            deg_to_rad(89)
        )

func _physics_process(delta):

    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir = Input.get_vector(
        "move_left",
        "move_right",
        "move_forward",
        "move_backward"
    )

    var direction = (transform.basis * Vector3(
        input_dir.x,
        0,
        input_dir.y
    )).normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()
