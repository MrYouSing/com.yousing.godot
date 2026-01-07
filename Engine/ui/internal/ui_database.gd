## A database for ui data management.
class_name UIDatabase extends Resource

static var instance:UIDatabase

@export_group("Database")
@export var dbid:int=-1
@export var models:Array[Resource]

var is_inited:bool
var query_map:Dictionary[int,Resource]
var find_map:Dictionary[StringName,Resource]

func init()->void:
	if is_inited:return
	is_inited=true
	#
	var i:int=-1;for it in models:
		i+=1;if it==null:continue
		if it.dbid<0:it.dbid=i
	if i>get_meta(&"capacity",32):
		query_map.clear()
		find_map.clear()
		for it in models:
			if it==null:continue
			query_map[it.dbid]=it
			find_map[it.resource_name]=it
	#
	if instance==null:instance=self

func query(i:int)->Resource:
	if !is_inited:init()
	#
	if !query_map.is_empty():
		var m:Resource=query_map.get(i,null)
		if m!=null:return m
	else:
		for it in models:if it!=null and it.dbid==i:return it
	return null

func find(k:StringName)->Resource:
	if !is_inited:init()
	#
	if !find_map.is_empty():
		var m:Resource=find_map.get(k,null)
		if m!=null:return m
	else:
		for it in models:if it!=null and it.resource_name==k:return it
	return null
