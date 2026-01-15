## A simplified [Window] for ui system.
class_name UIWindow extends Node

@export_group("Window")
@export var category:StringName

func get_text(k:StringName)->String:return tr(k,category)

func set_enabled(b:bool)->void:
	if b:show()
	else:hide()

func show()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func hide()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
