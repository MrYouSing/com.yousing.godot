## A bridge class between [url=https://github.com/bitbrain/beehave]Beehave[/url] and other systems.
@icon("res://addons/beehave/icons/action.svg")
class_name BeehaveActor extends AddonActor

@export_group("Beehave")

func addon(n:Node)->bool:
	return n is BeehaveLeaf

func setup(n:Node)->void:
	if n is BeehaveLeaf:n.before_run(context,null)

func teardown(n:Node)->void:
	pass
