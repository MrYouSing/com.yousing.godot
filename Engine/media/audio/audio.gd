## An audio player.
class_name Audio extends Media

func init()->void:
	if is_inited:return
	super.init()
	#
	if player!=null:
		if player is AudioStreamPlayer:type=1
		elif  player is AudioStreamPlayer2D:type=2
		elif  player is AudioStreamPlayer3D:type=3

func is_paused()->bool:
	if !is_inited:init()
	#
	if player!=null:return player.stream_paused
	else:return false

func pause()->void:
	if !is_inited:init()
	#
	if player!=null:player.stream_paused=true

func resume()->void:
	if !is_inited:init()
	#
	if player!=null:player.stream_paused=false
