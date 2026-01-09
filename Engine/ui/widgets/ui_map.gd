## A widget that displays world elements on UI.
class_name UIMap extends Node

static var s_layers:Array[Layer]=LangExtension.new_array(Layer,32)

static func register_at(v:Node,l:int)->void:
	s_layers[l].register(v)

static func unregister_at(v:Node,l:int)->void:
	s_layers[l].unregister(v)

static func register_by(v:Node,m:int)->void:
	var i:int=-1;for it in s_layers:
		i+=1;if m&(1<<i)!=0:it.register(v)

static func unregister_by(v:Node,m:int)->void:
	var i:int=-1;for it in s_layers:
		i+=1;if m&(1<<i)!=0:it.unregister(v)

@export_group("Map")
@export var layer:int
@export var world:Node
@export var bounds:Vector4
@export var canvas:Control
@export var rate:float=-1.0

var _time:float

func world_to_point(n:Node)->Vector2:
	if n==null or world==null or bounds.is_zero_approx():return Vector2.ZERO
	var v:Vector3=GodotExtension.get_global_position(n)
	var b:Vector4=bounds;var s:Vector2=canvas.size
	if world is Node3D:
		v=world.global_transform.inverse()*v
		v.y=-v.z
	elif world is Node2D:
		var u:Vector2=world.global_transform.inverse()*Vector2(v.x,v.y)
		v.x=u.x;v.y=u.x
	#
	v.x-=b.x;v.y-=b.y
	v.x*=s.x/b.z;v.y*=s.y/b.w
	return Vector2(v.x,v.y)

func world_to_angle(n:Node)->float:
	if n!=null and world!=null:
		if world is Node3D:if n is Node3D:
			return (world.global_basis.inverse()*n.global_basis).get_euler().y
		elif world is Node2D:if n is Node2D:return n.global_rotation-world.global_rotation
	return 0.0

func render_map()->void:
	if layer>=0:render_layer(s_layers[layer])

func render_layer(l:Layer)->void:
	if l!=null:for it in l.elements:
		if it.actor==null:continue
		if it.widget==null:it.widget=create_widget(it)
		render_element(it)

func create_widget(e:Element)->Node:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return null

func render_element(e:Element)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _ready()->void:
	if world==null:world=get_tree().root
	if canvas==null:canvas=GodotExtension.assign_node(self,"Control")

func _process(delta:float)->void:
	_time-=delta;if _time>0.0:return
	_time+=rate;
	#
	render_map()

class Element:
	static var s_pool:Collections.Pool=Collections.Pool.new(Element.new())
	static func obtain(c:Object,a:Node,w:Node)->Element:
		var e:Element=s_pool.obtain()
		e.context=c;e.actor=a;e.widget=w
		return e

	var context:Object
	var actor:Node
	var widget:Node

	func recycle()->void:
		if context!=null and context.has_method(&"_on_recycle"):
			context._on_recycle(self)
		actor=null;widget=null
		s_pool.recycle(self)

class Layer:
	var elements:Array[Element]

	func find(n:Node)->int:
		var i:int=-1;for it in elements:
			i+=1;if it.actor==n:return i
		return -1

	func register(n:Node)->void:
		if n==null:return
		var i:int=find(n);if i>=0:return
		elements.append(Element.obtain(self,n,null))

	func unregister(n:Node)->void:
		if n==null:return
		var i:int=find(n);if i<0:return
		elements[i].recycle();elements.remove_at(i)
