using Godot;

namespace YouSingStudio {
	public static partial class MathExtension
	{
		public const float EPSILON=1e-5f;
		public static float s_PixelsError=4;
		public static float s_PixelsPerUnit=32;

		public static int Step(this float thiz,float step) {
			float f=step*0.5f;f*=f;
			int n=0;while(thiz*thiz>=f) {
				thiz-=step;++n;
			}
			return n;
		}

		public static bool AlmostZero(this Vector2 thiz) {
			return thiz.LengthSquared()<EPSILON;
		}

		public static Vector2 ClampMagnitude(this Vector2 thiz,float length) {
			float f=thiz.LengthSquared();
			return f<EPSILON?Vector2.Zero:(thiz*(length/System.MathF.Sqrt(f)));
		}

		public static Vector2 Snap(this Vector2 thiz,Vector4 step) {
			Vector2 c=new Vector2(step.X,step.Y);
			return c+(thiz-c).Snapped(new Vector2(step.Z,step.W));
		}

		// Dpad(Up,Down,Left,Right)
		public static int GetDpad(this Vector2 thiz,bool yMatter=false) {
			float x=thiz.X,y=thiz.Y;
			if(yMatter?(x*x>y*y):(x*x>=y*y)) {
				if(x<0) {return 2;}
				else if(x>0) {return 3;}
			}else {// Up means y<0 in Godot.
				if(y<0) {return 0;}
				else if(y>0) {return 1;}
			}
			return -1;
		}
	}
}
