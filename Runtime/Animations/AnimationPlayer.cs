using Godot;

namespace YouSingStudio.Animations {
	public partial class AnimationPlayer
		:Godot.AnimationPlayer
	{
		[Export]public string animation="Idle";

		public override void _Ready() {
			if(!string.IsNullOrEmpty(animation)) {Play(animation);}
		}
	}
}
