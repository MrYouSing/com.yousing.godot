## A render wrapper for trail plugins.
class_name TrailRenderer extends Node

const TYPE_NOT_IMPLEMENTED:int=-1
## See [url=https://github.com/HungryProton/proton_trail]ProtonTrail[/url].
const TYPE_PROTON_TRAIL:int=0
## See [url=https://github.com/tcmug/godot_vaportrail]VaporTrail[/url].
const TYPE_VAPOR_TRAIL:int=1
## See [url=https://github.com/celyk/GPUTrail]GPUTrail[/url].
const TYPE_GPU_TRAIL:int=2
static var s_types:Dictionary[StringName,int]={
	&"ProtonTrail":TYPE_PROTON_TRAIL,
	&"proton_trail":TYPE_PROTON_TRAIL,
	&"VaporTrail":TYPE_VAPOR_TRAIL,
	&"GPUTrail3D":TYPE_GPU_TRAIL,
}

@export_group("Trail")
@export var trail:Node:
	set(x):
		if trail!=null:
			var b:bool=emitting;set_emitting(false)
			_type=TYPE_NOT_IMPLEMENTED;set_emitting(b)
		trail=x
		if x==null:_type=TYPE_NOT_IMPLEMENTED
		elif is_node_ready():_ready()
@export var emitting:bool=true:
	set=set_emitting
@export var duration:float=0.25:
	set=set_duration
@export var length:float=1.0:
	set=set_length
@export var color:Color=Color.WHITE:
	set=set_color
@export var texture:Texture2D:
	set=set_texture

var start:Node:
	get():
		if start==null:
			start=self
			_mask|=0x01
		return start
	set(x):
		_mask&=~0x01
		if x!=null:_mask|=0x02
		start=x

var end:Node:
	get():
		if end==null:
			end=ClassDB.instantiate(get_class())
			GodotExtension.add_node(end,self,false)
			GodotExtension.set_local_position(end,Vector3(0.0,length,0.0))
			_mask|=0x04
		return end
	set(x):
		_mask&=~0x04
		if x!=null:_mask|=0x08
		end=x

var _type:int=TYPE_NOT_IMPLEMENTED
var _mask:int

func get_material()->Material:
	match _type:
		TYPE_PROTON_TRAIL:
			return trail.material
		TYPE_VAPOR_TRAIL:
			return trail.get(&"visual/material")
		TYPE_GPU_TRAIL:
			var m:QuadMesh=trail.get(&"draw_pass_1") as QuadMesh
			if m!=null:return m.material
		TYPE_NOT_IMPLEMENTED:return null
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return null

func set_emitting(b:bool)->void:
	emitting=b
	match _type:
		TYPE_PROTON_TRAIL:
			trail.emit=b
			GodotExtension.set_enabled(trail._meshInstance,b)
			return
		TYPE_VAPOR_TRAIL:
			trail.set(&"emitting",b)
			# TODO: Clean up by code modification.
			return
		TYPE_GPU_TRAIL:
			if b:RenderingExtension.start_particles(trail)
			else:RenderingExtension.stop_particles(trail)
			return
		TYPE_NOT_IMPLEMENTED:return
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func set_duration(f:float)->void:
	duration=f
	match _type:
		TYPE_PROTON_TRAIL:
			trail.life_time=f
			return
		TYPE_VAPOR_TRAIL:
			trail.set(&"config/num_points",roundi(f/trail.get(&"config/update_interval")))
			return
		TYPE_GPU_TRAIL:
			trail.length_seconds=f
			return
		TYPE_NOT_IMPLEMENTED:return
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func set_length(f:float)->void:
	length=f
	if _mask&0x03!=0:
		GodotExtension.set_local_position(end,Vector3(0.0,f,0.0))
	match _type:
		TYPE_PROTON_TRAIL:
			trail._bottom.position=Vector3.ZERO
			trail._top.position=Vector3(0.0,f,0.0)
			return
		TYPE_VAPOR_TRAIL:
			trail.set(&"config/alignment",2)
			trail.set(&"visual/size",f)
			trail.position=Vector3(0.0,0.5*f,0.0)
			return
		TYPE_GPU_TRAIL:
			f*=0.5
			trail.transform=Transform3D(Basis.from_scale(Vector3.ONE*f),Vector3(0.0,f,0.0))
			return
		TYPE_NOT_IMPLEMENTED:return
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func set_color(c:Color)->void:
	color=c
	var m:Material=get_material();if m==null:return
	match _type:
		TYPE_NOT_IMPLEMENTED:return
		TYPE_GPU_TRAIL:
			m.set(&"shader_parameter/color",c)
			return
		_:
			RenderingExtension.material_set_color(m,0,c)
			return
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func set_texture(t:Texture2D)->void:
	texture=t
	var m:Material=get_material();if m==null:return
	match _type:
		TYPE_NOT_IMPLEMENTED:return
		TYPE_GPU_TRAIL:
			m.set(&"shader_parameter/tex",t)
			return
		_:
			RenderingExtension.material_set_texture(m,0,t)
			return
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _on_init()->void:
	match _type:
		TYPE_PROTON_TRAIL:
			GodotExtension.set_enabled(trail._meshInstance,false)

func _ready()->void:
	if trail!=null:
		GodotExtension.set_enabled(trail,true)
		_type=s_types.get(LangExtension.class_get(trail),TYPE_NOT_IMPLEMENTED)
		_on_init()
		set_emitting(emitting)
		set_duration(duration)
		set_length(length)
		set_color(color)
		set_texture(texture)
