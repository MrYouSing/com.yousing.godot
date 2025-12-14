class_name BaseTrigger extends Node

func is_trigger()->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false
