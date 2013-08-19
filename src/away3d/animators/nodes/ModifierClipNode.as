package away3d.animators.nodes
{
	import away3d.animators.states.*;
	import away3d.animators.data.*;
	
	/**
	 * A ModifierClipNode
	 */
	public class ModifierClipNode extends AnimationClipNodeBase
	{
		
		/**
		 * Creates a new <code>ModifierClipNode</code> object.
		 */
		public function ModifierClipNode()
		{
			_stateClass = ModifierAnimationState;
		}
		
		/**
		 * Returns a vector of SpriteSheetAnimationFrame representing the uv values of each animation frame in the clip.
		 */
		//public function get frames():Vector.<SpriteSheetAnimationFrame>
		//{
		//	return _frames;
		//}
		
		/**
		 * Adds a SpriteSheetAnimationFrame object to the internal timeline of the animation node.
		 *
		 * @param spriteSheetAnimationFrame The frame object to add to the timeline of the node.
		 * @param duration The specified duration of the frame in milliseconds.
		 */
		//public function addFrame(spriteSheetAnimationFrame:SpriteSheetAnimationFrame, duration:uint):void
		//{
		//	_frames.push(spriteSheetAnimationFrame);
		//	_durations.push(duration);
		//	_numFrames = _durations.length;
			
		//	_stitchDirty = false;
		//}
	}
}
