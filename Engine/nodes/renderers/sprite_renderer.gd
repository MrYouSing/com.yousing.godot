## A custom sprite renderer that is better than [AnimatedSprite2D] and [AnimatedSprite3D].
class_name SpriteRenderer extends Director

@export_group("Sprite")
@export var asset:SpriteAsset
@export var sprite:Sprite2D

func open(k:StringName)->void:
	if asset!=null:play(asset.find_clip(k))

func _ready()->void:
	if sprite==null:sprite=GodotExtension.assign_node(self,"Sprite2D")
	if sprite!=null:sprite.centered=false
	if asset!=null:play(asset.get_clip(0))

func _on_frame(f:Frame)->void:
	var r:Sprite2D=sprite
	if r==null or f==null:return
	var s:SpriteAsset.Sprite=f.object
	if s==null:return
	var a:SpriteAsset.Sheet=s.sheet
	#
	r.texture=a.texture
	if s.index>=0:
		r.region_enabled=false
		r.hframes=a.cols
		r.vframes=a.rows
		r.frame=s.index
	else:
		r.region_enabled=true
		r.region_rect=s.rect
	r.offset=s.offset
	#
	var e:StringName=f.key
	if !e.is_empty():invoke_event(e)

func _on_complete()->void:
	if clip!=null:
		var a:SpriteAsset.Atlas=clip.context
		if a!=null:
			match typeof(a.next):
				TYPE_INT:pass#return
				TYPE_STRING:pass#return
	super._on_complete()
