## A helper singleton for scene management.
class_name Stage extends Node

const k_keyword:StringName=&"YouSing_Stage"
static var s_create:Callable=func()->Object:
	var i:Stage=Stage.new();i.name=k_keyword
	GodotExtension.add_node(i,null,false)
	i._ready();return i

static var instance:Stage:
	get:return Singleton.try_instance(k_keyword,s_create)
	set(x):Singleton.set_instance(k_keyword,x)

@export_group("Stage")
@export var hidden:Node
@export var paths:Dictionary[StringName,StringName]

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
	var p:String=path(k);if !p.is_empty():
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
	var s:PackedScene=asset(k)
	if s!=null:
		var v:Node=s.instantiate();
		pool(k,v);return v
	return null

func spawn(o:Node,p:Node,m:Variant,w:bool=false)->Node:
	if o!=null:
		o=pool(o.name,o).obtain()
		GodotExtension.add_node(o,p,false)
		if w:o.global_transform=m
		else:o.transform=m
		#
		if o.has_method(&"_on_spawn"):o._on_spawn()
	return o

func despawn(o:Node)->void:
	if o!=null:
		if o.has_method(&"_on_despawn"):o._on_despawn()
		#
		var p:Collections.Pool=pool(o.name,null)
		if p!=null:
			GodotExtension.add_node(o,hidden,false)
			p.recycle(o)
		else:
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
	if !scenes.is_empty() and !a:unload(LangExtension.k_empty_string)
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

# Async Management

func get_loader(k:StringName)->Loader:
	for it in loaders:
		if it!=null and it.name==k:return it
	return null

## Callback([Node] or [Loader])
func prefab_async(k:StringName,c:Callable)->void:
	var p:Collections.Pool=pools.get(k,null)
	if p!=null:
		if !c.is_null():c.call(p.source)
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
		if !c.is_null():c.call(self)
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

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		if GodotExtension.s_root==null:
			GodotExtension.s_root=get_tree().root
		if hidden==null:
			if GodotExtension.s_hide==null:
				match GodotExtension.s_dimension:
					2:hidden=Node2D.new();
					3:hidden=Node3D.new();
				hidden.name=&"Hidden";hidden.visible=false
				GodotExtension.add_node(hidden,self,false)
			else:
				hidden=GodotExtension.s_hide;return
		if GodotExtension.s_hide==null:
			GodotExtension.s_hide=hidden

func _exit_tree()->void:
	if Singleton.exit_instance(k_keyword,self):
		pass

func _on_prefab(l:Loader)->void:
	if l.progress==1.0:
		var k:StringName=l.name;assets[k]=l.asset;
		l.asset=l.asset.instantiate();pool(k,l.asset)
	#
	loaders.erase(l);l.path=Loader.k_recycle

func _on_load(l:Loader)->void:
	if l.progress==1.0:
		var k:StringName=l.name;assets[k]=l.asset;
		if !l.arguments.is_empty():self.load(k,l.arguments[0])
	#
	loaders.erase(l);l.path=Loader.k_recycle
