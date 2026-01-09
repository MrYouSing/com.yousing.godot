/* <!-- Macro.Define bRemoveLicense=
true
 Macro.End --> */
/* <!-- Macro.Define Singleton
const k_keyword:StringName=&"YouSing_{0}"
const k_class:Variant={0}
static var exists:bool:
	get:return Engine.has_singleton(k_keyword)
static var instance:{0}:
	get:return Singleton.try_instance(k_keyword,k_class)
	set(x):Singleton.set_instance(k_keyword,x)
 Macro.End --> */
/* <!-- Macro.Table Replace
\r\n,\n
 Macro.End --> */

/* <!-- Macro.Call Singleton
Juggler,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
../animations/internal/juggler.gd,Singleton
 Macro.End --> */

/* <!-- Macro.Call Singleton
Stage,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
../nodes/scenes/stage.gd,Singleton
 Macro.End --> */

/* <!-- Macro.Call Singleton
Theater,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
../media/audio/theater.gd,Singleton
 Macro.End --> */

/* <!-- Macro.Call Singleton
UIManager,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
../ui/internal/ui_manager.gd,Singleton
 Macro.End --> */

/* <!-- Macro.Call Singleton
Game,
 Macro.End --> */
/* <!-- Macro.Replace Replace
 Macro.End --> */
/* <!-- Macro.Patch
../nodes/games/game.gd,Singleton
 Macro.End --> */