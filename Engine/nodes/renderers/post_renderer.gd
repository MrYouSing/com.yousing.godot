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
	Singleton.set_item(PostRenderer,layer,self)
	if instances[layer]!=self:push_warning("instances[%d]!=self."%layer)
	if region==null:region=GodotExtension.assign_node(self,"Control")
	#
	for it in shaders:
		if it==null:continue
		it.add_material(material)

func _exit_tree()->void:
	Singleton.unset_item(PostRenderer,layer,self)
	if GodotExtension.s_reparenting:return
	#
	for it in shaders:
		if it==null:continue
		it.remove_material(material)
