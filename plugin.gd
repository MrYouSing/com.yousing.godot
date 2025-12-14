@tool
extends EditorPlugin

var root:String="res://addons/yousing/"

func get_display(x:String)->String:
	return x.to_pascal_case()

func get_icon(x:String)->Texture2D:
	return null

func combine_path(a:String,b:String)->String:
	var x:bool=a.ends_with("/");
	var y:bool=b.ends_with("/");
	if x and y:return a+b.substr(1)
	elif x or y:return a+b
	else:return a+"/"+b

func get_scripts(p:String,e:String)->Array[String]:
	var l:Array[String];
	var d:DirAccess=DirAccess.open(p);if d!=null:
		for it in d.get_files():
			if e.is_empty() or it.ends_with(e):
				l.append(combine_path(p,it))#;print(combine_path(p,it))
		for it in d.get_directories():
			l.append_array(get_scripts(combine_path(p,it),e))
	return l

func set_types(r:String,l:Array[String],b:bool)->void:
	for it in l:
		var s:Script=load(r+it);if s==null:continue
		var c:StringName=s.get_global_name()
		var p:StringName=s.get_instance_base_type()
		if !ClassDB.is_parent_class(p,&"Node") and !ClassDB.is_parent_class(p,&"Resource"):
			continue
		#
		if b:
			add_custom_type(get_display(c),p,s,get_icon(c))
		else:
			remove_custom_type(get_display(c))

func _enter_tree():
	set_types("",get_scripts(root+"Engine/",".gd"),true)


func _exit_tree():
	set_types("",get_scripts(root+"Engine/",".gd"),false)
