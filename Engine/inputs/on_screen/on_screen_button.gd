## A button that is visually represented on-screen and triggered by touch.
class_name OnScreenButton extends OnScreenControl

@export_group("Button")
@export var action:StringName
@export var toggle:bool
@export var touch:TouchScreenButton
@export var image:TextureRect
@export_group("Press","press_")
@export var press_fade:float=0.0
@export var press_color:Color=Color.WHITE
@export var press_image:Texture2D
@export_group("Release","release_")
@export var release_fade:float=0.0
@export var release_color:Color=Color.WHITE
@export var release_image:Texture2D

var is_on:bool

func register(b:bool)->void:
	if touch!=null:
		if b:
			touch.pressed.connect(_change)
			touch.released.connect(_change)
		else:
			touch.pressed.disconnect(_change)
			touch.released.disconnect(_change)

func refresh()->void:
	if image!=null and touch!=null:
		var r:Rect2=image.get_global_rect()
		touch.global_position=r.get_center()
		set_size(touch.shape,r.size)
		draw()

func dirty()->bool:
	var b:bool=Input.is_action_pressed(action)
	if b!=is_on:is_on=b;return true
	else:return false

func draw()->void:
	render(is_on)

func render(b:bool)->void:
	is_on=b
	if image!=null:
		if b:set_image(image,press_color,press_image,press_fade)
		else:set_image(image,release_color,release_image,release_fade)

func _change()->void:
	var b:bool=touch.is_pressed()
	if toggle and b:b=not Input.is_action_pressed(action)
	#
	InputExtension.set_button(action,b)
	render(b)

func set_enabled(b:bool)->void:
	if touch!=null:touch.visible=b
	if image!=null:image.visible=b
	super.set_enabled(b)
