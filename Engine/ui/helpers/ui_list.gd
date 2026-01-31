## A loader class that makes [ItemList] and [Tree] easier.
class_name UIList extends Node

static var current:UIList

@export_group("List")
@export var category:StringName
@export var path:StringName
@export var root:Node
@export var container:Node
@export_group("UI")
@export var title:StringName
@export var tooltip:StringName
@export var mode:TreeItem.TreeCellMode
@export var range:Vector4
@export var clicks:MouseButtonMask=-1
@export var buttons:Array[StringName]
@export var icons:Array[Texture2D]
@export var tooltips:Array[StringName]

signal selected(a:Array[Element])
signal clicked(e:Element,b:StringName)

var elements:Array[Element]
var selection:Array[Element]
var _waiting:bool

func reload()->void:
	var tmp:UIList=current;current=self
	var r:Node=root
	if root==null:root=GodotExtension.s_root
	Asset.load_array(elements,path,Element)
	root=r
	current=tmp

func find(k:StringName)->Element:
	var i:int=-1;for it in elements:
		i+=1;if it!=null and it.name==k:
			if it.id<0:it.id=i
			return it
	return null

func rebuild()->void:
	if container==null:
		pass
	elif container is ItemList:
		container.clear()
		match container.select_mode:
			ItemList.SELECT_TOGGLE:LangExtension.add_signal(container,&"item_clicked",_list_clicked)
			ItemList.SELECT_MULTI:LangExtension.add_signal(container,&"multi_selected",_lists_selected)
			_:LangExtension.add_signal(container,&"item_selected",_list_selected)
		LangExtension.add_signal(container,&"empty_clicked",_empty_selected)
		var i:int=-1;for it in elements:
			i+=1;item(container,i,it)
	elif container is Tree:
		container.clear()
		if title.is_empty():
			container.column_titles_visible=false
		else:
			container.column_titles_visible=true
			container.set_column_title(0,tr(title,category))
			if !tooltip.is_empty():
				container.set_column_title_tooltip_text(0,tr(tooltip,category))
		LangExtension.add_signal(container,&"button_clicked",_clicked)
		match mode:
			TreeItem.CELL_MODE_CHECK:LangExtension.add_signal(container,&"item_edited",_selected)
			_:match container.select_mode:
				Tree.SELECT_SINGLE:LangExtension.add_signal(container,&"item_selected",_tree_selected)
				Tree.SELECT_MULTI:LangExtension.add_signal(container,&"multi_selected",_trees_selected)
		LangExtension.add_signal(container,&"empty_clicked",_empty_selected)
		var i:int=-1;for it in elements:
			i+=1;tree(container,i,it)

func item(c:ItemList,i:int,e:Element)->void:
	var t:Texture2D=e.icon;var k:StringName=tr(e.text,category)
	e.list=c;e.tree=null;e.item=null
	e.context=self;e.id=i
	#
	if t!=null:c.add_icon_item(t);c.set_item_text(i,k)
	else:c.add_item(k)
	if !e.tooltip.is_empty():c.set_item_tooltip(i,tr(e.tooltip,category))
	c.set_item_metadata(i,e)

func tree(c:Tree,i:int,e:Element)->TreeItem:
	var t:Texture2D=e.icon;var k:StringName=tr(e.text,category)
	var h:int=i<<16;var p:Element=null
	if e.parent>=0:p=elements[e.parent]
	var v:TreeItem=c.create_item(p.item if p!=null else null)
	e.tree=c;e.list=null;e.item=null
	e.context=self;e.id=i
	#
	e.item=v;i=0
	var b:bool=false;var m:int=mode;match mode:
		TreeItem.CELL_MODE_CUSTOM:
			m=0
		TreeItem.CELL_MODE_RANGE:
			if !range.is_zero_approx():
				k=LangExtension.k_empty_name;v.set_cell_mode(i,m)
				v.set_range_config(i,range.x,range.y,range.z,range.w!=0.0)
			b=true
		_:
			b=true
	v.set_cell_mode(i,m);v.set_editable(i,b)
	if t!=null:v.set_icon(i,t)
	if !k.is_empty():v.set_text(i,k)
	if !e.tooltip.is_empty():v.set_tooltip_text(i,tr(e.tooltip,category))
	v.set_metadata(i,e)
	for j in buttons.size():
		if e.buttons&(1<<j)!=0:
			v.add_button(i,icons[j],h|j,false,tr(tooltips[j],category),buttons[j])
	return v

func _selected()->void:
	selection.clear();_waiting=false
	for it in elements:if it!=null and it.selected():selection.append(it)
	if selected.has_connections():selected.emit(selection)
	#else:print(selection)

func _clicked(t:TreeItem,c:int,i:int,m:int)->void:
	m-=1;if clicks&(1<<m)==0:return
	var b:int=i&0xFFFF;i=(i>>16)&0xFFFF
	clicked.emit(elements[i],buttons[b])

func _wait_selected()->void:
	if _waiting:return
	_waiting=true
	Juggler.instance.delay_call(_selected,LangExtension.k_empty_array,Application.get_delta())

func _empty_selected(v:Vector2,m:int)->void:
	m-=1;if clicks&(1<<m)==0:return
	if container.has_method(&"deselect_all"):container.deselect_all()
	if mode==TreeItem.CELL_MODE_CHECK:for it in elements:if it!=null:it.deselect()
	_wait_selected()

func _list_clicked(i:int,v:Vector2,m:int)->void:
	m-=1;if clicks&(1<<m)==0:return
	_wait_selected()

func _list_selected(i:int)->void:
	_wait_selected()

func _lists_selected(i:int,b:bool)->void:
	_wait_selected()

func _tree_selected()->void:
	_wait_selected()

func _trees_selected(t:TreeItem,c:int,b:bool)->void:
	_wait_selected()

func _ready()->void:
	if container==null:container=self.get_node_or_null(^".")
	reload();rebuild()

class Element:
	# Persistent
	var name:StringName
	var text:StringName
	var icon:Texture2D
	var tooltip:StringName
	var buttons:int
	# Runtime
	var context:UIList
	var id:int=-1
	var parent:int=-1
	var node:Node
	var resource:Resource
	var list:ItemList
	var tree:Tree
	var item:TreeItem

	func selected()->bool:
		if item!=null:
			match context.mode:
				TreeItem.CELL_MODE_CHECK:return item.is_checked(0)
				_:return item.is_selected(0)
		if list!=null:
			return list.is_selected(id)
		return false

	func deselect()->void:
		if item!=null:
			match context.mode:
				TreeItem.CELL_MODE_CHECK:item.set_checked(0,false)

	func _set(k:StringName,v:Variant)->bool:
		match k:
			&"$icon":
				icon=IOExtension.load_asset(v)
				return true
			&"$node":
				if UIList.current!=null:node=UIList.current.root.get_node_or_null(v)
				return true
			&"$resource":
				resource=IOExtension.load_asset(v)
				return true
			&"$parent":
				var s:String=v
				if s.is_valid_int():
					parent=int(s)
				elif UIList.current!=null:
					var e:Element=UIList.current.find(s)
					if e!=null:parent=e.id
				return true
			&"$buttons":
				if UIList.current!=null:
					buttons=LangExtension.str_to_mask(v,UIList.current.buttons)
				return true
		return false
