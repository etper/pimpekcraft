extends CharacterBody3D

@export var speed := 6.0
@export var jump_velocity := 5.0

const GRAVITY = 9.8

func _ready():
    var inventory = Inventory.new()

    inventory.add_item(ItemDB.Block.DIRT,64)

    $Hotbar.setup(
        inventory,
        get_node("/root/Main/InventoryUi")
    )

    $PlayerInteraction.setup(
        inventory,
        get_node("/root/Main/InventoryUi")
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
