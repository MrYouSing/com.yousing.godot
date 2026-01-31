## A helper class that calls native dialogs from [DisplayServer].
class_name UIDialog extends UIWindow

@export_group("Dialog")
@export_enum("Dialog","Input","File","FileEx","Reserved 0","Reserved 1")
var type:int
@export var mode:DisplayServer.FileDialogMode
@export var title:StringName
@export var text:StringName
@export var texts:PackedStringArray
@export var options:Array[Dictionary]
@export var fallback:Window
@export var message:StringName

signal on_complete(r:Variant)

var result:String
var results:PackedStringArray
var option:Dictionary

func can_show(f:int)->bool:return DisplayServer.has_feature(f)

func get_texts()->PackedStringArray:
	var n:int=texts.size();var a:PackedStringArray
	if n>0:a.resize(n);for i in n:a[i]=get_text(texts[i])
	return a

func clear()->void:
	result=LangExtension.k_empty_string
	results.clear()
	option.clear()

func show()->void:
	clear()
	match type:
		0:if can_show(DisplayServer.FEATURE_NATIVE_DIALOG) and show_dialog():return
		1:if can_show(DisplayServer.FEATURE_NATIVE_DIALOG_INPUT) and show_input():return
		2:if can_show(DisplayServer.FEATURE_NATIVE_DIALOG_FILE) and show_file():return
		3:
			if can_show(DisplayServer.FEATURE_NATIVE_DIALOG_FILE_EXTRA) and show_file_ex():return
			elif can_show(DisplayServer.FEATURE_NATIVE_DIALOG_FILE) and show_file():return
	if fallback!=null:fallback.show()

func hide()->void:
	if fallback!=null:fallback.hide()

func complete()->void:
	if results.is_empty():
		if !result.is_empty():on_complete.emit(result)
	else:
		on_complete.emit(results)
	if fallback!=null:
		if results.is_empty():
			if !result.is_empty():fallback.emit_signal(message,result)
		else:
			fallback.emit_signal(message,results)

func show_dialog()->bool:
	var e:Error=DisplayServer.dialog_show(get_text(title),get_text(text),get_texts(),back_dialog)
	return e==Error.OK

func back_dialog(i:int)->void:
	result=texts[i];complete()

func show_input()->bool:
	var e:Error=DisplayServer.dialog_input_text(get_text(title),get_text(text),texts[0],back_input)
	return e==Error.OK

func back_input(s:String)->void:
	result=s;complete()

func show_file()->bool:
	var p:String=text
	var e:Error=DisplayServer.file_dialog_show(get_text(title),IOExtension.directory_name(p),IOExtension.file_name(p),get_meta(&"hidden",false),mode,texts,back_file)
	return e==Error.OK

func back_file(b:bool,a:PackedStringArray,i:int)->void:
	if b:
		if mode==DisplayServer.FILE_DIALOG_MODE_OPEN_FILES:
			results.append_array(a)
		else:
			result=a[i]
		complete()

func show_file_ex()->bool:
	var p:String=text
	var e:Error=DisplayServer.file_dialog_with_options_show(get_text(title),IOExtension.directory_name(p),"",IOExtension.file_name(p),get_meta(&"hidden",false),mode,texts,options,back_file_ex)
	return e==Error.OK

func back_file_ex(b:bool,a:PackedStringArray,i:int,d:Dictionary)->void:
	option.assign(d);back_file(b,a,i)

func _ready()->void:
	if fallback==null:fallback=GodotExtension.assign_node(self,"Window")
