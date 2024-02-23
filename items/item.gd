extends Area2D

signal picked_up

var textures: Dictionary = {
    "cherry": "res://assets/sprites/cherry.png",
    "gem": "res://assets/sprites/gem.png",
}


func _ready() -> void:
    body_entered.connect(on_body_entered)


func init(type: String, _position: Vector2) -> void:
    $Sprite2D.texture = load(textures[type])
    position = _position


func on_body_entered(body: CharacterBody2D) -> void:
    if body is Player:
        picked_up.emit()
        queue_free()