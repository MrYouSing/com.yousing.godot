## A helper singleton for scene management.
class_name Stage extends Node
# <!-- Macro.Patch Singleton
const k_keyword:StringName=&"YouSing_Stage"
const k_class:Variant=Stage
static var exists:bool:
	get:return Engine.has_singleton(k_keyword)
static var instance:Stage:
	get:return Singleton.try_instance(k_keyword,k_class)
	set(x):Singleton.set_instance(k_keyword,x)
# Macro.Patch -->
const k_meta_pool:StringName=&"META_STAGE_POOL"

@export_group("Stage")
@export var root:Node
@export var hidden:Node
@export var paths:Dictionary[StringName,String]

var assets:Dictionary[StringName,Resource]
var pools:Dictionary[StringName,Collections.Pool]
var loaders:Array[Loader]
var scenes:Array[Node]

# Asset Management

func path(k:StringName)->String:
	if paths.has(k):return "res://"+paths[k]
	return LangExtension.k_empty_string

func asset(k:StringName)->Resource:
	var v:Resource=assets.get(k,null)
	if v!=null:return v
	#
	var p:String=k if k.begins_with("res://") else path(k)
	if not p.is_empty():
		v=ResourceLoader.load(p);
		assets[k]=v;return v
	return null

# Pool Management

func pool(k:StringName,v:Node=null)->Collections.Pool:
	var p:Collections.Pool=pools.get(k,null)
	if p==null and v!=null:
		p=Collections.Pool.new(v)
		GodotExtension.add_node(v,hidden,false)
		#
		v.name=k;pools[k]=p
	return p

func prefab(k:StringName)->Node:
	var p:Collections.Pool=pools.get(k)
	if p!=null:return p.source
	#
	var r:Resource=asset(k)
	if r!=null:
		var v:Node=r.instantiate();_on_create(v)
		pool(k,v);return v
	return null

func unpack(r:Resource)->Node:
	if r==null:return null
	var k:StringName=IOExtension.file_name_only(r.resource_path)
	if pools.has(k):
		return pools[k].source
	else:
		var v:Node=r.instantiate();_on_create(v)
		pool(k,v);return v

func spawn(o:Node,p:Node,m:Variant,w:bool=false)->Node:
	if o!=null:
		var k:StringName=o.name;o=pool(k,o).obtain()
		GodotExtension.add_node(o,p,false);o.set_meta(k_meta_pool,k)
		if m!=null:
			if w:o.global_transform=m
			else:o.transform=m
		#
		_on_spawn(o)
	return o

func despawn(o:Node)->void:
	if o!=null:
		_on_despawn(o)
		#
		var p:Collections.Pool=pool(o.get_meta(k_meta_pool,o.name),null)
		if p!=null:
			GodotExtension.add_node(o,hidden,false)
			p.recycle(o)
		else:
			_on_destroy(o)
			GodotExtension.destroy(o)

# Scene Management

func find(k:StringName)->Node:
	for it in scenes:
		if it!=null and it.name==k:
			return it
	return null

func show(e:String)->void:
	for it in scenes:
		if it!=null and it.name.match(e):
			GodotExtension.add_node(it,null,false)

func hide(e:String)->void:
	for it in scenes:
		if it!=null and it.name.match(e):
			GodotExtension.add_node(it,hidden,false)

func load(k:StringName,a:bool=false)->void:
	if not scenes.is_empty() and not a:unload(LangExtension.k_empty_string)
	var s:PackedScene=asset(k);if s==null:return
	#
	var n:Node=s.instantiate();
	GodotExtension.add_node(n,null,false)
	#
	n.name=k;scenes.append(n)

func unload(k:StringName)->void:
	if scenes.is_empty():return
	#
	if k.is_empty():
		for it in scenes:
			GodotExtension.remove_node(it)
		scenes.clear()
	else:
		var i:int=-1;for it in scenes:
			i+=1;if it!=null and it.name==k:
				GodotExtension.remove_node(it)
				scenes.remove_at(i);break;

func load_level(l:Variant,h:bool=false,a:bool=false,c:Callable=LangExtension.k_empty_callable)->void:
	var k:StringName=LangExtension.k_empty_name;var s:bool=true
	match typeof(l):
		TYPE_NIL:
			return
		TYPE_STRING:
			k=IOExtension.file_name_only(l)
			paths[k]=l
		TYPE_STRING_NAME:
			k=l
		TYPE_OBJECT:
			k=IOExtension.file_name_only(l.resource_path)
			assets[k]=l;s=false
	if h and scenes.has(k):show(k)
	elif s and c.is_valid():load_async(k,c,a);return
	else:self.load(k,a)
	if c.is_valid():c.call(find(k))

func unload_level(l:Variant,h:bool=false)->void:
	var k:StringName=LangExtension.k_empty_name
	match typeof(l):
		TYPE_NIL:return
		TYPE_STRING:k=IOExtension.file_name_only(l)
		TYPE_STRING_NAME:k=l
		TYPE_OBJECT:k=IOExtension.file_name_only(l.resource_path)
	if h and scenes.has(k):hide(k)
	else:self.unload(k)

# Async Management

func get_loader(k:StringName)->Loader:
	for it in loaders:
		if it!=null and it.name==k:return it
	return null

## Callback([Node] or [Loader])
func prefab_async(k:StringName,c:Callable)->void:
	var p:Collections.Pool=pools.get(k,null)
	if p!=null:
		if not c.is_null():c.call(p.source)
	else:
		var l:Loader=get_loader(k)
		if l!=null:
			l.on_done.connect(c,CONNECT_ONE_SHOT)
		else:
			l=Loader.obtain(k,self,_on_prefab)
			l.on_done.connect(c,CONNECT_ONE_SHOT)
			loaders.append(l);l.load(path(k))

## Callback([Node] or [Loader])
func load_async(k:StringName,c:Callable,a:bool=false)->void:
	if assets.has(k):
		self.load(k,a);
		if not c.is_null():c.call(self)
	else:
		var l:Loader=get_loader(k)
		if l!=null:
			l.on_done.connect(c,CONNECT_ONE_SHOT)
		else:
			l=Loader.obtain(k,self,_on_load)
			l.on_done.connect(c,CONNECT_ONE_SHOT)
			LangExtension.set_item(l.arguments,0,a)
			loaders.append(l);l.load(path(k))

# Messages

func _on_create(n:Node)->void:
	if n!=null:
		pass

func _on_destroy(n:Node)->void:
	if n!=null:
		push_warning("Stage destroy {0}({1})[{2}]".format([n.name,n.get_class(),n.get_script()]))

func _on_spawn(n:Node)->void:
	if n!=null:
		var m:Node=n.get_node_or_null(^"Main")
		if m!=null:n=m
		if n.has_method(&"_on_spawn"):n._on_spawn()
		else:GodotExtension.set_enabled(n,true)

func _on_despawn(n:Node)->void:
	if n!=null:
		var m:Node=n.get_node_or_null(^"Main")
		if m!=null:n=m
		if n.has_method(&"_on_despawn"):n._on_despawn()
		else:GodotExtension.set_enabled(n,false)

func _on_prefab(l:Loader)->void:
	if l.progress==1.0:
		var k:StringName=l.name;assets[k]=l.asset;
		l.asset=l.asset.instantiate();pool(k,l.asset)
	#
	loaders.erase(l);l.path=Loader.k_recycle

func _on_load(l:Loader)->void:
	if l.progress==1.0:
		var k:StringName=l.name;assets[k]=l.asset;
		if not l.arguments.is_empty():self.load(k,l.arguments[0])
	#
	loaders.erase(l);l.path=Loader.k_recycle

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		#
		if root==null:
			root=GodotExtension.s_root
			if root==null:root=get_tree().root
		GodotExtension.s_root=root
		#
		if hidden==null:
			if GodotExtension.s_hide==null:
				match GodotExtension.s_dimension:
					2:hidden=Node2D.new();
					3:hidden=Node3D.new();
				hidden.name=&"Hidden";hidden.visible=false
				GodotExtension.add_node(hidden,self,false)
			else:
				hidden=GodotExtension.s_hide
		GodotExtension.s_hide=hidden

func _exit_tree()->void:
	if Singleton.exit_instance(k_keyword,self):
		pass
