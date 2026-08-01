## A variant loader that depends on keywords.
class_name VariantLoader extends Runnable

static var s_keywords:Dictionary[StringName,StringName]

@export_group("Variant")
@export var keyword:StringName
@export var loader:Node
@export var variants:Dictionary[StringName,String]

func run()->void:
	var k:StringName=s_keywords.get(keyword,LangExtension.k_empty_name)
	var p:String=variants.get(&"Default",LangExtension.k_empty_string)
	p=variants.get(k,p)
	if p.is_empty():return
	self.load(p)

func load(p:String)->void:
	_loaded(load(p))

func _loaded(r:Resource)->void:
	if r==null:return
	if loader==null:loader=self
	#
	if loader!=self:
		if loader is Func:
			loader.invoke_with(r);return
		elif loader.has_method(&"_loaded"):
			loader._loaded(r);return
	# Default loader.
	if loader is InstancePlaceholder:
		loader.create_instance(true,r)
	else:
		var n:Node=r.instantiate()
		GodotExtension.add_node(n,loader,false)

func _ready()->void:
	if Application.is_busy() and target==null:
		run.call_deferred()
	else:
		super._ready()
