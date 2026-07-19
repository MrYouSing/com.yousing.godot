## A tool renderer for [CompositorEffect]s.
class_name PostRenderer extends CanvasItem

static var instances:Array[PostRenderer]=LangExtension.alloc_array(PostRenderer,32)

@export_group("Post Effect")
@export var layer:int
@export var region:Node
@export var texture:Texture2D
@export var shaders:Array[PostShader]

func get_region()->Rect2:
	if region.has_method(&"get_rect"):return region.get_rect()
	else:return get_viewport_rect()# Full-Screen

func _draw()->void:
	var r:Rect2=get_region();r.position=Vector2.ZERO# Local-Space
	if texture==null:draw_rect(r,Color.WHITE)
	else:draw_texture_rect(texture,r,false)

func _ready()->void:
	if GodotExtension.is_prefab(self):return
	Singleton.set_item(PostRenderer,layer,self)
	#
	if region==null:region=GodotExtension.assign_node(self,"Control")
	var m:Material=material
	if m==null:return
	for it in shaders:
		if it==null:continue
		it.add_material(m)
	_start.call_deferred()

func _start()->void:
	var i:PostRenderer=instances[layer]
	if i==self:
		var p:Node=get_parent()
		if p!=null and not p is CanvasLayer:
			var c:CanvasLayer=CanvasLayer.new()
			c.layer=layer;c.name="Layer_"+name
			GodotExtension.add_node(c,p,false)
			GodotExtension.add_node(self,c,false)
	else:
		GodotExtension.add_node(self,i.get_parent(),false)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	Singleton.unset_item(PostRenderer,layer,self)
	#
	var m:Material=material
	if m==null:return
	for it in shaders:
		if it==null:continue
		it.remove_material(m)
