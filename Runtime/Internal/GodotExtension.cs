using Godot;

namespace YouSingStudio {
	public static partial class GodotExtension {

		public static Vector2 Input_GetVector(string[] thiz) {
			Vector2 v=Input.GetVector(thiz[0],thiz[1],thiz[2],thiz[3]);
			v.Y*=-1.0f;// To Godot space.
			return v.ClampMagnitude(1.0f);
		}

		public static void CheckComponent<T>(this Node thiz,ref T value) where T:Node {
			if(thiz!=null&&value==null) {
				//value=thiz as T;
				if(value==null) {value=thiz.GetNodeOrNull(typeof(T).Name) as T;}
				if(value==null) {thiz.GetParent().CheckComponent<T>(ref value);}
			}
		}
	}
}
