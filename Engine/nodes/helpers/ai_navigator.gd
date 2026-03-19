## A wrapper class for [NavigationAgent2D] and [NavigationAgent3D].
class_name AINavigator extends Node

static var k_classes:PackedStringArray=[
	"Node2D","RigidBody2D","CharacterBody2D",
	"Node3D","RigidBody3D","CharacterBody3D"]

@export_group("Motor")
@export var root:Node
@export var agent:Node
@export var speed:float=10.0
@export var smooth:Vector2=Vector2(-1.0,60)
@export var turn:Vector2=Vector2(-1.0,60.0)
@export_group("Animation")
@export var model:Node
@export var tree:AnimationTree
@export var path:StringName
@export var blend:Vector2=Vector2(-1.0,60)
@export var threshold:Vector2=Vector2(0.1,10.0)

var _enabled:bool
var _type:int
var _delta:float
var _direction:Variant

func get_direction()->Variant:
	if _direction==null:return agent.velocity
	else:return _direction

func sleep()->void:
	if _type<=2:_on_2d(Vector2.ZERO)
	else:_on_3d(Vector3.ZERO)

func stop()->void:
	_enabled=false
	set_physics_process(false)
	#
	if root!=null:root.set(&"freeze",true)
	sleep()

func move(v:Variant)->void:
	#
	if not _enabled:
		set_physics_process(true)
		_on_tree(-1.0)
		if root!=null:root.set(&"freeze",false)
		sleep()
	#
	_enabled=true;_direction=null
	if agent!=null:agent.set_target_position(v)

func look(v:Variant)->void:
	_direction=v

func _on_2d(v:Vector2)->void:
	match _type:
		0:var p:Vector2=root.global_position;root.global_position=p.move_toward(p+v,speed*_delta)
		1:root.linear_velocity=v
		2:root.velocity=v;root.move_and_slide()

func _on_3d(v:Vector3)->void:
	match _type:
		3:var p:Vector3=root.global_position;root.global_position=p.move_toward(p+v,speed*_delta)
		4:root.linear_velocity=v
		5:root.velocity=v;root.move_and_slide()

func _on_turn(d:float)->void:
	var v:Variant=get_direction();if v.is_zero_approx():return
	if _type<=2:model.global_rotationrotation=MathExtension.float_lerp(model.global_rotationrotation,MathExtension.clocking_at(v),turn,d)
	else:model.global_basis=MathExtension.quat_lerp(model.global_basis,MathExtension.looking_at(v),turn,d)

func _on_tree(d:float)->void:
	var u:Variant=tree.get(path);var f:float;var v:Vector2
	match typeof(u):
		TYPE_FLOAT:
			f=agent.velocity.length()/threshold.y
			if d>=0.0:f=MathExtension.float_fade(MathExtension.float_lerp(u,f,smooth,d),f,threshold.x)
			tree.set(path,f)
		TYPE_VECTOR2:
			if _type<=2:
				f=agent.velocity.rotated(-model.global_rotation)/threshold.y
				if d>=0.0:f=MathExtension.float_fade(MathExtension.float_lerp(u.length(),f,smooth,d),f,threshold.x)
				tree.set(path,f)
			else:
				var w:Vector3=model.global_basis.inverse()*agent.velocity;v=Vector2(w.x/threshold.y,w.z/threshold.y)
				if d>=0.0:v=MathExtension.vec2_fade(MathExtension.vec2_lerp(u,v,smooth,d),v,threshold.x)
				tree.set(path,v)

func _ready()->void:
	if root==null:root=self
	if model==null:model=root
	#
	_type=k_classes.find(root.get_class())
	var s:String="NavigationAgent2D" if _type<=2 else "NavigationAgent3D"
	#
	if agent==null:agent=GodotExtension.assign_node(root,s)
	if _type<=2:LangExtension.try_signal(agent,&"velocity_computed",_on_2d)
	else:LangExtension.try_signal(agent,&"velocity_computed",_on_3d)

func _process(d:float)->void:
	if _enabled:
		if not turn.is_zero_approx():_on_turn(d)
		if tree!=null:_on_tree(d)
	elif _direction!=null:
		if not turn.is_zero_approx():_on_turn(d)

func _physics_process(d:float)->void:
	_delta=d
	if agent==null or not _enabled:
		pass
	elif _type<=2:
		if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map())==0:stop();return
		if agent.is_navigation_finished():stop();return
		var v:Vector2=agent.get_next_path_position()
		v=(v-root.global_position).normalized()*speed
		v=MathExtension.vec2_lerp(agent.velocity,v,smooth,d)
		if agent.avoidance_enabled:agent.set_velocity(v)
		else:_on_2d(v)
	else:
		if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map())==0:stop();return
		if agent.is_navigation_finished():stop();return
		var v:Vector3=agent.get_next_path_position()
		v=(v-root.global_position).normalized()*speed
		v=MathExtension.vec3_lerp(agent.velocity,v,smooth,d)
		if agent.avoidance_enabled:agent.set_velocity(v)
		else:_on_3d(v)
