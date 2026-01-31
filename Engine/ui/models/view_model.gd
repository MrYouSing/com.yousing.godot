## The data and event binder for [url=https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel]MVVM[/url].
class_name ViewModel extends Resource

static var s_binder_classes:Dictionary[StringName,int]
static var s_binder_contents:Array[StringName]
static var s_binder_events:Array[StringName]
static var s_binder_notices:Array[StringName]
static var s_binder_engines:PackedStringArray
static var s_binder_users:PackedStringArray

static func add_type(e:PackedStringArray,u:PackedStringArray,t:StringName)->void:
	var i:int=t.find(".");if i>=0:t=t.substr(0,i)
	if ClassDB.class_exists(t):
		if !e.has(t):e.append(t)
	else:
		if !u.has(t):u.append(t)

static func check_member(c:StringName,m:StringName,k:StringName)->void:
	if !k.is_empty() and !LangExtension.class_has(c,m,k):
		Application.debug("{1}@{2} is Not found in {0}.".format([c,m,k]),2)

static func register_binder(k:StringName,c:StringName,e:StringName,n:StringName)->void:
	if !s_binder_classes.has(k):
		if ClassDB.class_exists(k):
			check_member(k,&"property",c)
			check_member(k,&"signal",e)
			check_member(k,&"method",n)
		add_type(s_binder_engines,s_binder_users,k)
		var i:int=s_binder_contents.size()
		s_binder_classes[k]=i
		s_binder_contents.append(c)
		s_binder_events.append(e)
		s_binder_notices.append(n)

static func inherit_binder(k:StringName,...a:Array)->void:
	var i:int=s_binder_classes.get(k,-1)
	if i>=0:
		var e:PackedStringArray;var u:PackedStringArray
		add_type(e,u,k);for it in a:add_type(e,u,it);s_binder_classes[it]=i
		print("ViewModel register "+k+":\n\tEngine Types:\n\t\t"+"\n\t\t".join(e)+"\n\tUser Types:\n\t\t"+"\n\t\t".join(u))
		LangExtension.merge_strings(s_binder_engines,e);LangExtension.merge_strings(s_binder_users,u)

static func find_binder(v:Object,k:StringName,t:StringName)->int:
	var i:int=-1;if v!=null:
		var s:Script=v.get_script()
		while s!=null and i<0:i=find_class(s.get_global_name(),k,t);s=s.get_base_script()
		var c:String=v.get_class()
		while !c.is_empty() and i<0:i=find_class(c,k,t);c=ClassDB.get_parent_class(c)
	return i

static func find_class(c:StringName,k:StringName,t:StringName)->int:
	var i:int=-1
	i=s_binder_classes.get(c+"."+k,-1);if i<0:i=s_binder_classes.get(c+"."+t,-1);if i<0:i=s_binder_classes.get(c,-1)
	return i

@export_group("Bindings")
@export var paths:Array[NodePath]
@export var names:Array[StringName]

func bind(m:Object,k:StringName,v:Node,p:NodePath)->Binding:
	if m!=null and v!=null:
		v=v.get_node_or_null(p);if v!=null:
			var t:int=typeof(m.get(k));var i:int=find_binder(v,k,type_string(t))
			if i>=0:
				var b:Binding=Binding.new()
				b.type=t;b.name=k;b.view=v
				b.content=s_binder_contents[i]
				b.event=s_binder_events[i]
				b.notice=s_binder_notices[i]
				return b
	return null

func setup(m:Object,v:Node)->Stub:
	if m!=null and v!=null:
		var s:Stub=Stub.new();var it:Binding;var k:StringName
		for i in names.size():
			k=names[i];it=bind(m,k,v,paths[i]);if it!=null:
				if s.bindings.has(k):s.bindings[k+str(i)]=it
				else:s.bindings[k]=it
		s.context=self;s.model=m
		s.bind();return s
	return null

func teardown(s:Stub)->void:
	if s!=null:s.dispose()

func _model_changed(s:Stub,a:Object,b:Object)->void:
	if a!=null and a.has_method(&"_bind"):a._bind(null)
	if b!=null and b.has_method(&"_bind"):b._bind(s)

class Binding:
	var stub:Stub
	var name:StringName
	var type:int
	var view:Object
	var content:StringName
	var event:StringName
	var notice:StringName

	var _busy:bool

	func bind()->void:
		if view!=null:
			display=value
			var d:Dictionary=LangExtension.info_signal(view,event)
			if !d.is_empty():
				var c:Callable=_updated if d.args.is_empty() else _changed
				if !view.is_connected(event,c):view.connect(event,c)
			if !notice.is_empty() and !view.has_method(notice):
				notice=LangExtension.k_empty_name
		LangExtension.add_signal(stub,name,_synced)

	func unbind()->void:
		if view!=null:
			var d:Dictionary=LangExtension.info_signal(view,event)
			if !d.is_empty():
				var c:Callable=_updated if d.args.is_empty() else _changed
				if view.is_connected(event,c):view.disconnect(event,c)
		LangExtension.remove_signal(stub,name,_synced)

	# Model Side

	var value:Variant:
		get():
			if stub!=null:
				if stub.model!=null:return stub.model.get(name)
			return null
		set(x):
			if stub!=null:
				if stub.model!=null:stub.model.set(name,x)
				stub.broadcast(name,x)

	func refresh()->void:
		_synced(value)

	func _synced(x:Variant)->void:# M to V
		if _busy:return
		_busy=true
		display=x
		_busy=false

	# View Side

	var display:Variant:
		get:
			if view==null:return null
			return view.get(content)
		set(x):
			if view==null:return
			if notice.is_empty():view.set(content,x)
			else:view.call(notice,x)

	func _updated()->void:# V to M
		if _busy:return
		_busy=true
		if view!=null:value=view.get(content)
		_busy=false

	func _changed(x:Variant)->void:# V to M
		if _busy:return
		_busy=true
		value=x
		_busy=false

class Stub:
	var context:Object
	var model:Object:
		set(x):
			if x!=model:
				if context!=null:context._model_changed(self,model,x)
				model=x;refresh()
	var bindings:Dictionary[StringName,Binding]
	signal changed(m:Object)

	func dispose()->void:
		unbind()
		model=null;context=null;bindings.clear()

	func refresh()->void:
		var it:Binding;for b in bindings.values():
			it=b;if it!=null and it.stub!=null:it.refresh()
		broadcast(LangExtension.k_empty_name,null)

	func bind()->void:
		unbind()
		var it:Binding;for b in bindings.values():
			it=b;if it!=null:it.stub=self;it.bind()

	func unbind()->void:
		var it:Binding;for b in bindings.values():
			it=b;if it!=null and it.stub!=null:it.unbind();it.stub=null

	func broadcast(k:StringName,v:Variant)->void:
		if !k.is_empty():emit_signal(k,v)
		changed.emit(model)

	func verify(k:StringName)->bool:
		var it:Binding=bindings.get(k,null)
		if it!=null:
			var m:Variant=it.value;var v:Variant=it.display
			match it.type:
				TYPE_FLOAT:if is_zero_approx(m-v):return false
				_:if m==v:return false
			broadcast(k,m);return true
		return false

	func _get(k:StringName)->Variant:
		var it:Binding=bindings.get(k,null)
		if it!=null:return it.value
		else:return null
	
	func _set(k:StringName,v:Variant)->bool:
		var it:Binding=bindings.get(k,null)
		if it!=null:it.value=v;return true
		return false
