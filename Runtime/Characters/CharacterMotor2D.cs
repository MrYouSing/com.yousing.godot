using Godot;
using YouSingStudio.Animations;
using static YouSingStudio.GodotExtension;

namespace YouSingStudio.Characters {
	public partial class CharacterMotor2D
		:Godot.CharacterBody2D
	{
		[Export]public string[] inputs=new string[]{"move_left","move_right","move_down","move_up","run"};
		[Export]public Vector2 speed=new Vector2(10,20);
		[Export]public Vector4 snapping=new Vector4();
		public Vector2 input;
		[Export]public DirectionalAnimator2D animator;
		[Export]public bool collide=true;
		protected bool m_Running;
		protected Vector2 m_Destination;

		public override void _Ready() {
			this.CheckComponent<DirectionalAnimator2D>(ref animator);
			if(animator!=null) {
				animator.inputs=null;
			}
			ResetDestination();
		}

		public override void _Process(double delta) {
			input=Input_GetVector(inputs);
			m_Running=Input.GetActionStrength(inputs[4])>=0.5f;
		}
	
		public override void _PhysicsProcess(double delta) {
			var dir=GetInput();
			var col=this.MoveAndCollide(GetVelocity(dir)*(float)delta);
			if(animator!=null) {
				if(col!=null) {
					ResetDestination();
					if(collide) {dir=Vector2.Zero;}
					else if(input.AlmostZero()) {dir=Vector2.Zero;}
				}
				animator.input=dir.ClampMagnitude(m_Running?2.0f:1.0f);
			}
		}

		protected virtual void ResetDestination() {
			m_Destination=snapping.Z==0.0f?this.Position:
				this.Position.Snap(snapping);
		}

		protected virtual Vector2 GetInput() {
			if(snapping.Z!=0.0f) {
				Vector2 pos=this.Position;
				if(input.AlmostZero()) {
					pos=m_Destination-pos;float e=MathExtension.s_PixelsError;
					if(pos.LengthSquared()<=e*e) {this.Position=m_Destination;}
					else {return pos.Normalized();}
				}else {
					m_Destination=pos.Snap(snapping);
						pos=input.Sign();
						pos.X*=snapping.Z;pos.Y*=snapping.W;
					m_Destination+=pos;
				}
			}
			return input;
		}

		public virtual Vector2 GetVelocity(Vector2 direction) {
			if(!direction.AlmostZero()) {
				float s=m_Running?speed.Y:speed.X;
				return direction*(s*MathExtension.s_PixelsPerUnit);
			}
			return Vector2.Zero;
		}
	}
}
