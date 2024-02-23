class_name Player
extends CharacterBody2D

signal life_changed
signal died

@export var gravity: float = 750.0
@export var run_speed: float = 150.0
@export var jump_speed: float= -300.0

enum State { IDLE, RUN, JUMP, HURT, DEAD }
var state = State.IDLE
var life: int: set = set_life

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
    change_state(State.IDLE)


func _physics_process(delta) -> void:
    velocity.y += gravity * delta
    get_input()

    move_and_slide()
    if state == State.JUMP and is_on_floor():
        change_state(State.IDLE)
    if state == State.JUMP and velocity.y > 0:
        animation_player.play("jump_down")


func set_life(value: int) -> void:
    life = value
    life_changed.emit(life)
    if life <= 0:
        change_state(State.DEAD)


func change_state(new_state: State)  -> void:
    state = new_state
    match state:
        State.IDLE:
            animation_player.play("idle")
        State.RUN:
            animation_player.play("run")
        State.HURT:
            animation_player.play("hurt")
            velocity.y = -200
            velocity.x = -100 * sign(velocity.x)
            life -= 1
            await get_tree().create_timer(0.5).timeout
            change_state(State.IDLE)
        State.JUMP:
            animation_player.play("jump_up")
        State.DEAD:
            died.emit()
            hide()


func get_input() -> void:
    if state == State.HURT:
        return

    var left = Input.is_action_pressed("move_left")
    var right = Input.is_action_pressed("move_right")
    var jump = Input.is_action_just_pressed("jump")

    velocity.x = 0
    if left:
        velocity.x -= run_speed
        sprite.flip_h = true
    if right:
        velocity.x += run_speed
        sprite.flip_h = false
    if jump and is_on_floor():
        change_state(State.JUMP)
        velocity.y = jump_speed
    
    if state == State.IDLE and velocity.x != 0:
        change_state(State.RUN)
    if state == State.RUN and velocity.x == 0:
        change_state(State.IDLE)
    if state in [State.IDLE, State.RUN] and !is_on_floor():
        change_state(State.JUMP)


func reset(_position) -> void:
    life = 3
    position = _position
    show()
    change_state(State.IDLE)


func hurt()  -> void:
    if state != State.HURT:
        change_state(State.HURT)