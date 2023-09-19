using Godot;
using static YouSingStudio.GodotExtension;

namespace YouSingStudio.Animations {
	public partial class DirectionalAnimator2D
		:Godot.AnimationPlayer
	{
		// Input
		[Export]public string[] inputs=new string[]{"move_left","move_right","move_down","move_up"};
		public Vector2 input;
		// Output
		[Export]public int[] directions=new int[]{0,1,2,3};
		public int direction=-1;
		public float speed=0.0f;
		// Rendering
		[Export]public Godot.Sprite2D renderer;
		[Export]public bool yAnimate=false;
		[Export]public bool yMatter=false;
		[Export]public string[] animations=new string[]{"Idle","Walk","Run"};

		public override void _Ready() {
			this.CheckComponent<Godot.Sprite2D>(ref renderer);
			this.Play(animations[0]);
		}

		public override void _Process(double delta) {
			if((inputs?.Length??0)>=4) {
				input=Input_GetVector(inputs);
				GD.Print(speed);
			}
			// Resolve direction.
			int d=input.GetDpad(yMatter);float sqr=input.LengthSquared();
			if(d>=0&&d!=direction) {
				direction=d;
			}
			// Fix animation.
			if(sqr!=speed*speed) {
				speed=System.MathF.Sqrt(sqr);
				//
			 	this.Play(animations[speed.Step(1.0f)]);
			}
			if(renderer!=null&&direction>=0) {
				Vector2I fc=renderer.FrameCoords;
					if(yAnimate) {fc.X=directions[direction];}
					else {fc.Y=directions[direction];}
				renderer.FrameCoords=fc;
			}
		}
	
	}
}
