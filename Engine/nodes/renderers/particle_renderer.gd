## A tool class for playing [CPUParticles2D],[GPUParticles2D],[CPUParticles3D] and [GPUParticles3D].
class_name ParticleRenderer extends Node

@export_group("Particle")
@export var duration:float
@export var root:Node
@export var nodes:Array[Node]

var _call:int=Juggler.k_invalid_id

func set_enabled(b:bool)->void:
	if root!=null:root.set(&"visibility",b)
	if b:play()
	else:stop()

func play()->void:
	for it in nodes:if it!=null:_set_enabled(it,true)
	if duration>0.0:
		_call=Juggler.instance.delay_call(kill,LangExtension.k_empty_array,duration)

func stop()->void:
	for it in nodes:if it!=null:_set_enabled(it,false)
	if _call!=Juggler.k_invalid_id:
		Juggler.instance.kill_call(_call)
	_call=Juggler.k_invalid_id

func kill()->void:
	if Stage.exists:Stage.instance.despawn(self)

func _set_enabled(n:Node,b:bool)->void:
	if b:n.set(&"emitting",b)
	else:GodotExtension.stop_particles(n)
	GodotExtension.set_enabled(n,b)

func _on_spawn()->void:
	if is_node_ready():play()

func _on_despawn()->void:
	stop()

func _ready()->void:
	_on_spawn()
