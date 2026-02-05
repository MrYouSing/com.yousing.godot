## A [Button] container that makes [NativeMenu],[PopupMenu] and [MenuButton] easier.
class_name UIMenu extends UIWindow

@export_group("Menu")
@export var menu:Node
@export var path:String
@export var button:Node
@export var anchor:Control.LayoutPreset=Control.PRESET_CENTER_TOP
@export var offset:Vector2
@export var join:StringName
@export var value:int:
	set(x):_value_changed(x);value_changed.emit(x);value=x
## See [signal Range.value_changed]
signal value_changed(i:int)

var is_created:bool
var popup:PopupMenu
var rid:RID
var keyboard:KeyboardInput
var indexes:Array[int]
var items:Array[Entry]

func _ready()->void:
	_value_changed(value)
	# TODO:Fixed issue https://github.com/godotengine/godot/issues/112862
	if is_popup() and Application.get_platform()!="macOS":
		keyboard=KeyboardInput.current

func _process(d:float)->void:
	if keyboard!=null:for it in items:
		if it!=null and keyboard.shortcut(it.key):_on_press(it.id)

func _exit_tree()->void:
	if rid.is_valid():NativeMenu.clear(rid)
	is_created=false;rid=LangExtension.k_empty_rid

func _on_press(i:int)->void:
	if join.is_empty():
		value=i
	else:
		i=1<<i;var b:bool=value&i!=0
		if b:value&=~i
		else:value|=i

func _on_click(i:int)->void:
	var e:Entry=items[i]
	if e==null:return
	if e.action.is_valid():
		e.action.call()
	else:
		var m:Node=menu
		if m==null or e.method.is_empty():return
		if m.has_method(e.method):m.callv(e.method,e.args)

## [method Range._value_changed]
func _value_changed(v:int)->void:
	if !is_popup():return
	var t:String;if join.is_empty():
		var i:int=-1;for it in indexes:
			i+=1;if v==i:
				set_item_checked(it,true)
				t=get_item_text(it)
			else:
				set_item_checked(it,false)
	else:
		var a:PackedStringArray;var n:int=indexes.size()
		var i:int=-1;for it in indexes:
			i+=1;if v&(1<<i)!=0:
				set_item_checked(it,true)
				n-=1;a.append(get_item_text(it))
			else:
				set_item_checked(it,false)
		if v==0:t=get_text(&"Nothing")
		elif n==0:t=get_text(&"Everything")
		else:t=get_text(join).join(a)
	if button!=null:button.set(&"text",t)

func show()->void:
	if is_popup():
		if button!=null&&button.has_method(&"show_popup"):button.show_popup()
		else:show_popup(get_position())
	else:
		var m:Node=menu if menu!=null else self
		m.set(&"visible",true)

func hide()->void:
	if is_popup():
		if popup!=null:popup.hide()
	else:
		var m:Node=menu if menu!=null else self
		m.set(&"visible",false)

func to_popup(n:Node)->PopupMenu:
	if n!=null:
		if n is PopupMenu:return n
		if n.has_method(&"get_popup"):return n.get_popup()
	return null

func get_position()->Vector2:
	var m:PopupMenu=get_popup();var r:Rect2
	if button!=null and button.has_method(&"get_global_rect"):
		r=button.get_global_rect()
	#
	if m==null:# Native
		r.position=PointerInput.get_mouse_position(DisplayServer.SCREEN_PRIMARY)
	elif m.is_native_menu():
		r.position=PointerInput.get_mouse_position(-DisplayServer.SCREEN_OF_MAIN_WINDOW)
	elif !is_zero_approx(r.size.length_squared()):
		m.show();var s:Vector2=m.size
		var p:Vector2=UITransform.preset_to_vec2(anchor)
		var o:Vector2=MathExtension.rect_position(r,p)
		p.x*=-1.0# Inside
		p.y=p.y-1.0# Outside
		r.position=o+s*p+offset
	return r.position

func add_menu(m:PopupMenu,e:Entry)->void:
	if m==null or e==null:return
	var i:Texture2D=e.icon
	var t:String=get_text(e.text)
	#
	if e.mask&Mask.Separator!=0:
		m.add_separator(t);return
	elif e.mask&Mask.Submenu!=0:
		var s:Node=get_node_or_null(NodePath(e.text))
		if s==null:m.add_item(t,e.id,e.key)
		else:m.add_submenu_node_item(t,to_popup(s),e.id)
	elif t==null:
		if e.mask&Mask.Radio!=0:m.add_radio_check_item(t,e.id,e.key)
		elif e.mask&Mask.Toggle!=0:m.add_check_item(t,e.id,e.key)
		else:m.add_item(t,e.id,e.key)
	else:
		if e.mask&Mask.Radio!=0:m.add_icon_radio_check_item(i,t,e.id,e.key)
		elif e.mask&Mask.Toggle!=0:m.add_icon_check_item(i,t,e.id,e.key)
		else:m.add_icon_item(i,t,e.id,e.key)
	#
	if e.mask&Mask.Disable!=0:m.set_item_disabled(e.index,true)
	if e.mask&Mask.Check!=0:m.set_item_checked(e.index,true)
	if !e.tooltip.is_empty():m.set_item_tooltip(e.index,get_text(e.tooltip))
	m.set_item_metadata(e.index,e)

func add_native(m:RID,e:Entry)->void:
	if !m.is_valid() or e==null:return
	var i:Texture2D=e.icon
	var t:String=get_text(e.text)
	var c:Callable=_on_press
	var k:Callable=c
	#
	if e.mask&Mask.Separator!=0:
		NativeMenu.add_separator(m);return
	elif e.mask&Mask.Submenu!=0:
		var s:Node=get_node_or_null(NodePath(e.text))
		if s==null or !s.has_method(&"get_rid"):NativeMenu.add_item(m,t,c,k,e.id,e.key)
		else:NativeMenu.add_submenu_item(m,t,s.get_rid(),e.id)
	elif t==null:
		if e.mask&Mask.Radio!=0:NativeMenu.add_radio_check_item(m,t,c,k,e.id,e.key)
		elif e.mask&Mask.Toggle!=0:NativeMenu.add_check_item(m,t,c,k,e.id,e.key)
		else:NativeMenu.add_item(m,t,c,k,e.id,e.key)
	else:
		if e.mask&Mask.Radio!=0:NativeMenu.add_icon_radio_check_item(m,i,t,c,k,e.id,e.key)
		elif e.mask&Mask.Toggle!=0:NativeMenu.add_icon_check_item(m,i,t,c,k,e.id,e.key)
		else:NativeMenu.add_icon_item(m,i,t,c,k,e.id,e.key)
	#
	if e.mask&Mask.Disable!=0:NativeMenu.set_item_disabled(m,e.index,true)
	if e.mask&Mask.Check!=0:NativeMenu.set_item_checked(m,e.index,true)
	if !e.tooltip.is_empty():NativeMenu.set_item_tooltip(m,e.index,get_text(e.tooltip))

func add_button(m:Node,e:Entry)->void:
	if m==null or e==null or button==null:return
	#
	var b:Node=button.duplicate()
	m.add_child(b);draw_button(b,e)
	if LangExtension.exist_signal(b,&"pressed"):b.connect(&"pressed",_on_click.bind(e.index))

func draw_button(b:Node,e:Entry)->void:
	if b==null or e==null:return
	var i:Texture2D=e.icon
	var t:String=get_text(e.text)
	#
	b.set(&"visible",true)
	b.set(&"text",t);b.set(&"icon",i)
	if !e.tooltip.is_empty():b.set(&"tooltip_text",get_text(e.tooltip))

func create()->void:
	if is_created:return
	is_created=true
	#
	if path.is_empty():return
	if !Asset.load_array(items,path,Entry):return
	popup=to_popup(menu)
	if popup!=null:
		popup.clear(true);popup.size=Vector2i.ZERO
		popup.id_pressed.connect(_on_press)
	elif menu==null:# Native
		rid=NativeMenu.create_menu()
	else:
		var i:int=-1;for it in items:
			i+=1;it.index=i
			add_button(menu,it)
		return
	var j:int=0;var n:int=items.size();indexes.resize(n)
	var i:int=-1;for it in items:
		i+=1;it.index=i
		if it.id<0 and it.mask&Mask.Separator==0:
			indexes[j]=i;it.id=j;j+=1
		add_item(it)
	if j<n:indexes.resize(j)

func is_popup()->bool:
	if !is_created:create()
	return popup!=null or rid.is_valid()

func show_popup(p:Vector2)->void:
	if !is_created:create()
	if popup!=null:popup.position=p;popup.show();return
	if rid.is_valid():NativeMenu.popup(rid,p);return

func get_popup()->PopupMenu:
	if !is_created:create()
	return popup

func get_rid()->RID:
	if !is_created:create()
	return rid

func add_item(e:Entry)->void:
	if !is_created:create()
	if popup!=null:add_menu(popup,e);return
	if rid.is_valid():add_native(rid,e);return

func get_item_text(i:int)->String:
	if !is_created:create()
	if popup!=null:return popup.get_item_text(i)
	if rid.is_valid():return NativeMenu.get_item_text(rid,i)
	return LangExtension.k_empty_string

func set_item_checked(i:int,b:bool)->void:
	if !is_created:create()
	if popup!=null:popup.set_item_checked(i,b);return
	if rid.is_valid():NativeMenu.set_item_checked(rid,i,b);return

class Entry:
	var text:StringName
	var icon:Texture2D
	var mask:Mask
	# Optional
	var id:int=-1
	var key:int
	var index:int
	var tooltip:StringName
	# Event
	var action:Callable=LangExtension.k_empty_callable
	var method:StringName
	var args:Array

	func _set(k:StringName,v:Variant)->bool:
		match k:
			&"$mask":
				mask=LangExtension.str_to_mask(v,k_mask_names)
				return true
			&"$key":
				key=LangExtension.str_to_mask(v,KeyboardInput.k_keys)
				return true
			&"$icon":
				icon=IOExtension.load_asset(v)
				return true
			&"$args":
				args=LangExtension.str_to_args(v,";")
				return true
		return false

enum Mask {
	Check    = 0x01,
	Toggle   = 0x02,
	Radio    = 0x04,
	Disable  = 0x10,
	Separator= 0x20,
	Submenu  = 0x40
}

const k_mask_names:PackedStringArray=[
	"Check",
	"Toggle",
	"Radio",
	"",
	"Disable",
	"Separator",
	"Submenu",
	""
]
