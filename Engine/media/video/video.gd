## A video player.
class_name Video extends Media

func init()->void:
	if is_inited:return
	super.init()
	#
	if player!=null:
		if player is VideoStreamPlayer:
			type=1;player.loop=false

func is_playing()->bool:
	if !is_inited:init()
	#
	if type==1:return player.is_playing()
	else:return false
