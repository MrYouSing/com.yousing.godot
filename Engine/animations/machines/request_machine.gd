## A helper machine for [AnimationNodeOneShot],[AnimationNodeTransition] and custom requests.
class_name RequestMachine extends Node

static var s_documents:Dictionary[String,Document]

static func get_document(f:String,b:bool=false)->Document:
	var d:Document=s_documents.get(f,null)
	if d==null and b:
		d=Document.new();d.load(f)
		s_documents.set(f,d)
	return d

@export_group("Request")
@export var path:String
@export var context:Node
@export var fallback:Array
@export var bindings:Dictionary[StringName,StringName]

var _doc:Document
var _call:int=Juggler.k_invalid_id
var _request:Request
var _fallback:Request

func stop()->void:
	Juggler.try_kill(self)
	if _request!=null and not _request.stop.is_empty():
		_on_request(_doc.dict.get(_request.stop,null))
	_request=null

func play(k:StringName)->bool:
	stop()
	#
	if _doc==null:
		_doc=get_document(path,true)
		_fallback=Request.from_args(context,fallback)
		if context==null:context=GodotExtension.assign_node(self,"AnimationTree")
	#
	var r:Request=_doc.dict.get(k,null)
	if r!=null:_on_request(r)
	elif _fallback==null:return false
	else:_fallback.name=k;_on_request(_fallback)
	return true

func _on_request(r:Request)->void:
	if r==null or context==null:return
	_request=r
	#
	var p:StringName=r.path
	if bindings.has(p):p=bindings[p]
	if not _do_request(r,p):return
	# Next
	var n:Request=_doc.dict.get(r.next,null);if n==null:return
	if r.wait>0.0:_call=Juggler.instance.delay_call(_on_request,[n],r.wait)
	else:_on_request(n)

func _do_request(r:Request,p:StringName)->bool:
	match r.type:
		# Object
		Type.Set:
			match r.args.size():
				1:
					context.set(p,r.args[0])
				2:
					var n:Node=context.get_node_or_null(r.args[0])
					if n!=null:n.set(p,r.args[1])
		Type.Call:
			match r.args.size():
				1:
					context.callv(p,r.args[0])
				2:
					var n:Node=context.get_node_or_null(r.args[0])
					if n!=null:n.callv(p,r.args[1])
		# Animation
		Type.Play:
			#
			var o:Object=r.thiz
			if o==null and not p.is_empty():o=context.get(p)
			if o==null:o=context
			#
			var n:int=r.args.size()
			var k:StringName=LangExtension.k_empty_string if n<=1 else r.args[1]
			if k.is_empty():k=r.name
			#
			match n:
				4:o.call(r.args[0],k,r.args[2],r.args[3])
				3:o.call(r.args[0],k,r.args[2])
				1,2:o.call(r.args[0],k)
				_:return false
		Type.Random:
			match r.args.size():
				1:var a:Variant=r.args[0];r=_doc.dict.get(a[randi()%a.size()],null)
				2:r=_doc.dict.get(r.args[0][MathExtension.random_level(1.0,r.args[1])],null)
			_on_request(r);return false
		# Sync
		Type.Shoot:
			match r.args.size():
				1:# Stop
					if r.args[0]:context.set(p,AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
					else:context.set(p,AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
				3:# Fade
					context.set(p,AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				_:
					context.set(p,AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		Type.Trans:
			match r.args.size():
				2:# Fade
					context.set(p,r.args[0])
				1:
					context.set(p,r.args[0])
		# Misc
		Type.Wait:
			if not p.is_empty():
				var f:float=get_meta(&"request_wait",0.1)
				_call=Juggler.instance.repeat_call(_on_wait,[r,p],f,f)
			return false
		Type.Custom:
			if r.send.is_valid():
				return r.send.call(context,r,p)
			else:
				return false
		_:
			return false
	return true

func _on_wait(r:Request,p:StringName)->void:
	if context.get(p)==r.args[0]:
		Juggler.try_kill(self)
		_on_request(_doc.dict.get(r.next,null))

func _on_toggle(c:Object,b:bool)->void:
	_on_event(c,&"On" if b else &"Off")

func _on_blend(c:Object,f:float)->void:
	pass

func _on_event(c:Object,e:StringName)->void:
	play(e)

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	_on_event(c,k)

enum Type {
	None=-1,
	Set,
	Call,
	Play,
	Random,
	Shoot,
	Trans,
	Wait,
	Count,
	Custom=-2,
}

class Request:
	static func from_args(n:Node,a:Array)->Request:
		var c:int=a.size();if c==0:return null
		var r:Request=Request.new()
		match c:
			7:
				r.name=a[0]
				r.type=a[1]
				r.path=a[2]
				r.args=a[3]
				r.stop=a[4]
				r.wait=a[5]
				r.next=a[6]
			0:
				pass
			_:
				if typeof(a[0])==TYPE_NODE_PATH:r.thiz=n.get_node_or_null(a[0])
				else:r.thiz=n.get(a[0])
				r.type=Type.Play;r.stop=a[1]
				c-=2;r.args.resize(c)
				for i in c:r.args[i]=a[2+i]
		return r
	#
	var name:StringName
	var type:Type
	var path:StringName
	var args:Array
	# Control
	var stop:StringName
	var wait:float
	var next:StringName
	# Runtime
	var thiz:Object
	var send:Callable

	func _set(k:StringName,v:Variant)->bool:
		match k:
			&"$type":type=LangExtension.str_to_enum(v,Type);return true
			&"$args":args=LangExtension.str_to_args(v,";");return true
		return false

class Document:
	var list:Array[Request]
	var dict:Dictionary[StringName,Request]
	var refs:Array[Object]

	func load(f:String)->void:
		#
		var t:Array[PackedStringArray]=Asset.load_table(f)
		if t!=null:LangExtension.array_add_table(list,t,Request)
		else:list.clear()
		#
		dict.clear();for it in list:dict[it.name]=it
