## An animation for mixables([Media],[BaseMixer] and [SkeletonModifier3D]).
class_name MixerAnimation extends StateMachine

@export_group("Mixer")
@export var mixers:Array[Node]
@export var snapshot:Snapshot
@export var classes:PackedStringArray
@export var scripts:Array[Resource]=[
preload("res://addons/yousing/Engine/media/internal/media.gd")
]
@export var names:Array[StringName]=[
&"volume"
]

func key_of(o:Object)->StringName:
	var i:int=LangExtension.class_of(o,classes,scripts)
	if i>=0:return names[i]
	else:return &"weight"

func _on_dirty()->void:
	super._on_dirty()
	#
	var n:int=mixers.size()
	if snapshot==null and n!=0:
		var s:Snapshot=Snapshot.new()
		s.paths.resize(n);var k:StringName
		var i:int=-1;for it in mixers:
			i+=1;if it==null:continue
			k=key_of(it);s.paths[i]=NodePath(k)
			s.samples[it.name]=it.get(k)
		snapshot=s

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	stop_tween()
	super._on_state(c,k,v,t)
	var s:Snapshot=v;if v==null:
		var tmp:Tween=play_tween() if tween==null else tween
		var i:int=-1;for it in mixers:
			i+=1;if it==null:continue
			k=it.name;Transition.current=it
			t.to_tween(tmp,it,snapshot.paths[i],s.samples.get(k,snapshot.samples.get(k)))
