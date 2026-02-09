## The abstract class for video.
class_name AbsVideo extends Media

@export_group("Video")
@export var container:AspectRatioContainer
@export var aspect:UICanvas.AspectRatio:
	set(x):aspect=x;_size_changed()
@export var speed:float=1.0:
	set(x):speed=x;_speed_changed()

func has_size()->bool:
	return is_playing()

func get_size()->Vector2:
	return player.get_size()

func _size_changed()->void:
	if has_size():UICanvas.fit_control(container,player,aspect,get_size())

func _speed_changed()->void:
	player.speed=speed

func _ready()->void:
	if !url.is_empty() and !is_playing():
		open(url);play()
	UICanvas.register(self,0,_size_changed)

func _exit_tree()->void:
	UICanvas.unregister(self,0,_size_changed)
