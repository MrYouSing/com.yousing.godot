## The Godot version of [url=https://docs.unity3d.com/Packages/com.unity.ugui@2.6/api/UnityEngine.EventSystems.UIBehaviour.html]UIBehaviour[/url].
class_name UIBehaviour extends GDBehaviour
# <!-- Macro.Patch AutoGen
signal awake()
func _awake()->void:awake.emit()
signal start()
func _start()->void:start.emit()
signal on_destroy()
func _on_destroy()->void:on_destroy.emit()
signal on_enable()
func _on_enable()->void:on_enable.emit()
signal on_disable()
func _on_disable()->void:on_disable.emit()
signal on_spawn()
func _on_spawn()->void:on_spawn.emit()
signal on_despawn()
func _on_despawn()->void:on_despawn.emit()
signal on_enter()
func _on_enter()->void:on_enter.emit()
signal on_exit()
func _on_exit()->void:on_exit.emit()
signal on_down()
func _on_down()->void:on_down.emit()
signal on_up()
func _on_up()->void:on_up.emit()
signal on_click()
func _on_click()->void:on_click.emit()
signal on_select()
func _on_select()->void:on_select.emit()
signal on_deselect()
func _on_deselect()->void:on_deselect.emit()
# Macro.Patch -->
@export_group("UI")
@export var control:Control

func _ready()->void:
	if control==null:control=GodotExtension.assign_node(self,"Control") as Control
	if control!=null:
		LangExtension.try_signal(control,&"mouse_entered",_on_enter)
		LangExtension.try_signal(control,&"mouse_exited",_on_exit)
		LangExtension.try_signal(control,&"button_down",_on_down)
		LangExtension.try_signal(control,&"button_up",_on_up)
		LangExtension.try_signal(control,&"pressed",_on_click)
		LangExtension.try_signal(control,&"focus_entered",_on_select)
		LangExtension.try_signal(control,&"focus_exited",_on_deselect)
	super._ready()

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	#
	if control!=null:
		LangExtension.remove_signal(control,&"mouse_entered",_on_enter)
		LangExtension.remove_signal(control,&"mouse_exited",_on_exit)
		LangExtension.remove_signal(control,&"button_down",_on_down)
		LangExtension.remove_signal(control,&"button_up",_on_up)
		LangExtension.remove_signal(control,&"pressed",_on_click)
		LangExtension.remove_signal(control,&"focus_entered",_on_select)
		LangExtension.remove_signal(control,&"focus_exited",_on_deselect)
	super._exit_tree()
