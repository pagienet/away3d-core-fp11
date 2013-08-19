package away3d.animators.states
{
	import away3d.arcane;
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	
	use namespace arcane;
	
	public class ModifierAnimationState extends AnimationClipState
	{
	 	private var _clipNode:ModifierClipNode;
	 	private var _modifierFrame:ModifierFrame;
		
		function ModifierAnimationState(animator:IAnimator, clipNode:ModifierClipNode)
		{
			super(animator, clipNode );
			
			_clipNode = clipNode;
			//todo allow custom frame based modifiers values
			_modifierFrame = new ModifierFrame();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get currentFrameData():ModifierFrame
		{
			return _modifierFrame;
		}
		
		 
		/**
		 * returns the total frames for the current animation.
		 */
		arcane function get totalFrames():uint
		{
			return  0;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateFrames():void
		{
			ModifierAnimator(_animator).dispatchCycleEvent();
		}
	}
}
