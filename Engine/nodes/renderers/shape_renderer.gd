## A tool class for rendering [Shape2D], [Shape3D] and other shapes.
class_name ShapeRenderer extends Node

static var s_shapes:Dictionary[String,Dictionary]={
	# Shape3D
	"BoxShape3D":{
		&"x":^"size:x",
		&"y":^"size:y",
		&"z":^"size:z",
		&"w":0
	},
	"CapsuleShape3D":{
		&"x":&"radius",
		&"y":&"height",
		&"z":&"radius",
		&"w":1
	},
	"CylinderShape3D":{
		&"x":&"bottom_radius",
		&"y":&"height",
		&"z":&"top_radius",
		&"w":2
	},
	"SphereShape3D":{
		&"x":&"radius",
		&"y":&"radius",
		&"z":&"radius",
		&"w":3
	},
	# Shape2D
	"RectangleShape2D":{
		&"x":^"size:x",
		&"y":^"size:y",
		&"z":1.0,
		&"w":0
	},
	"CapsuleShape2D":{
		&"x":&"radius",
		&"y":&"height",
		&"z":&"radius",
		&"w":1
	},
	"CircleShape2D":{
		&"x":&"radius",
		&"y":&"radius",
		&"z":&"radius",
		&"w":3
	},
	# SpringBoneCollision3D
	"SpringBoneCollisionPlane3D":{
		&"x":1.0,
		&"y":0.01,
		&"z":1.0,
		&"w":0
	},
	"SpringBoneCollisionCapsule3D":{
		&"x":&"radius",
		&"y":&"height",
		&"z":&"radius",
		&"w":1
	},
	"SpringBoneCollisionSphere3D":{
		&"x":&"radius",
		&"y":&"radius",
		&"z":&"radius",
		&"w":3
	},
	# Others
	"CollisionShape3D":{
		&"shape":&"shape"
	},
	"CollisionShape2D":{
		&"shape":&"shape"
	},
	"GPUClothCollider":{
		&"root":&"target",
		&"x":gpu_cloth_x,
		&"y":gpu_cloth_y,
		&"z":gpu_cloth_z,
		&"w":gpu_cloth_w,
	}
}

static func gpu_cloth_x(o:Object)->float:
	if o!=null:
		var i:int=o.get(&"shape")
		match i:
			2:return o.extents.x*2.0
			1:return o.radius
			0:return o.radius
	return 0.0

static func gpu_cloth_y(o:Object)->float:
	if o!=null:
		var i:int=o.get(&"shape")
		match i:
			2:return o.extents.y*2.0
			1:return o.height
			0:return o.radius
	return 0.0

static func gpu_cloth_z(o:Object)->float:
	if o!=null:
		var i:int=o.get(&"shape")
		match i:
			2:return o.extents.z*2.0
			1:return o.radius
			0:return o.radius
	return 0.0

static func gpu_cloth_w(o:Object)->float:
	if o!=null:
		var i:int=o.get(&"shape")
		match i:
			2:return 0.0
			1:return 1.0
			0:return 3.0
	return 0.0

static func eval_float(o:Object,v:Variant)->float:
	match typeof(v):
		TYPE_INT,TYPE_FLOAT:return v
		TYPE_STRING_NAME:return o.get(v)
		TYPE_NODE_PATH:return o.get_indexed(v)
		TYPE_CALLABLE:return v.call(o)
	return 0.0

static func eval_size(o:Object)->Vector4:
	var v:Vector4=Vector4.ZERO
	if o!=null:
		var s:Script=o.get_script()
		var d:Dictionary=s_shapes.get(o.get_class() if s==null else\
			String(s.get_global_name()),LangExtension.k_empty_dictionary)
		if not d.is_empty():
			if d.has(&"shape"):
				v=eval_size(o.get(d.shape))
			else:
				v.x=eval_float(o,d.x)
				v.y=eval_float(o,d.y)
				v.z=eval_float(o,d.z)
				v.w=eval_float(o,d.w)
	return v

static func eval_mesh(m:Mesh,v:Vector4)->Mesh:
	if m==null:
		match int(v.w):
			0:m=BoxMesh.new();m.size=Vector3(v.x,v.y,v.z)
			1:m=CapsuleMesh.new();m.radius=v.x;m.height=v.y
			2:m=CylinderMesh.new();m.bottom_radius=v.x;m.height=v.y;m.top_radius=v.z
			3:m=SphereMesh.new();m.radius=v.x;m.height=v.y*2.0
	else:
		match int(v.w):
			0:m.size=Vector3(v.x,v.y,v.z)
			1:m.radius=v.x;m.height=v.y
			2:m.bottom_radius=v.x;m.height=v.y;m.top_radius=v.z
			3:m.radius=v.x;m.height=v.y*2.0
	return m

static func eval_root(n:Node)->Node:
	if n!=null:
		var s:Script=n.get_script()
		var d:Dictionary=s_shapes.get(n.get_class() if s==null else\
			String(s.get_global_name()),LangExtension.k_empty_dictionary)
		if not d.is_empty():
			var v:Variant=d.get(&"root",null)
			if v!=null:
				var p:Node=null
				match typeof(v):
					TYPE_NODE_PATH:
						p=n.get_node_or_null(v)
					TYPE_STRING_NAME:
						v=n.get(v)
						match typeof(v):
							TYPE_NODE_PATH:p=n.get_node_or_null(v)
							TYPE_OBJECT:p=v
				if p!=null:return p
	return n

@export_group("Shape")
@export var tag:StringName
@export var color:Color=Color.WHITE
@export var material:Material
@export var nodes:Array[Node]

var _shown:bool
var _actors:Array[Node]

func set_enabled(b:bool)->void:
	if b==_shown:return
	_shown=b
	#
	if b:for i in nodes.size():_render(i)
	else:for it in _actors:GodotExtension.set_enabled(it,b)

func _render(i:int)->void:
	var n:Node=nodes[i];if n==null:return
	var a:Node=null
	if i>=_actors.size():
		if n.is_class("Node3D"):a=MeshInstance3D.new()
		else:a=MeshInstance2D.new()
		#
		a.name="{0}_Shape_{1}".format([name,"%02d"%i])
		GodotExtension.add_node(a,eval_root(n),false)
		_actors.append(a)
	else:
		a=_actors[i]
		GodotExtension.set_enabled(a,true)
	if a==null:return
	#
	var s:Vector4=eval_size(n)
	var m:Mesh=eval_mesh(a.mesh,s)
	if material!=null:m.material=material
	a.set(&"modulate",color)# For CanvasItem
	a.mesh=m

func _ready()->void:
	var b:bool=RenderingExtension.s_tags.has(tag)
	if b:b=self.visible
	set_enabled(b)
