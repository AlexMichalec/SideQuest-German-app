extends Button

@export var tint : Color
var scale_up : Vector2
var scale_standard  : Vector2
var scaling_up = false
var scaling_down = false

# Called when the node enters the scene tree for the first time.
func _ready():
	recolor()
	%AnimationPlayer.play("RESET")
	scale = Vector2(2,2)
	print(size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func recolor():
	scale = Vector2(2,2)
	%Sprite2D.material.set_shader_parameter("given_color", tint)


func _on_mouse_entered():
	%AnimationPlayer.play("scale_up")
	%AnimationPlayer.speed_scale = 1
	return
	if scaling_up:
		return
	scaling_up = true
	scaling_down = false
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scale",scale_up,0.5)


func _on_mouse_exited():
	%AnimationPlayer.play_backwards("scale_up")
	%AnimationPlayer.speed_scale = 2
	return
	if scaling_down:
		return
	scaling_down = true
	scaling_up = false
	var tween = get_tree().create_tween()
	tween.tween_property(self,"scale",scale_standard,0.3)
