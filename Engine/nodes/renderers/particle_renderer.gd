## A tool class for playing [CPUParticles2D],[GPUParticles2D],[CPUParticles3D] and [GPUParticles3D].
class_name ParticleRenderer extends Node

@export_group("Particle")
@export var duration:float
@export var root:Node
@export var nodes:Array[Node]

var _call:int=Juggler.k_invalid_id
var _anim:AnimationPlayer

func set_enabled(b:bool)->void:
	if root!=null:root.set(&"visible",b)
	if b:play()
	else:stop()

func play()->void:
	for it in nodes:if it!=null:_set_enabled(it,true)
	if _anim!=null:_anim.play(_anim.autoplay)
	if duration>0.0:
		_call=Juggler.instance.delay_call(kill,LangExtension.k_empty_array,duration)

func stop()->void:
	for it in nodes:if it!=null:_set_enabled(it,false)
	if _anim!=null:_anim.stop()
	Juggler.try_kill(self)

func kill()->void:
	if Stage.exists:Stage.instance.despawn(self)

func _set_enabled(n:Node,b:bool)->void:
	if b:n.set(&"emitting",b)
	else:RenderingExtension.stop_particles(n)
	GodotExtension.set_enabled(n,b)

func _on_spawn()->void:
	play()

func _on_despawn()->void:
	stop()

func _ready()->void:
	if GodotExtension.is_prefab(self):return
	#
	var n:Node=root;if root==null:n=self
	_anim=n.get_node_or_null(^"AnimationPlayer") as AnimationPlayer
	#
	if not GodotExtension.in_stage(self):_on_spawn()
