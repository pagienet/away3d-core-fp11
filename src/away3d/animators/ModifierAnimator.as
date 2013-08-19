package away3d.animators
{
	import away3d.animators.AnimatorBase;
	import away3d.animators.IAnimator;
	import away3d.animators.data.*;
	import away3d.animators.states.*;
	import away3d.animators.transitions.*;
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.SubMesh;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.*;
	import away3d.core.math.MathConsts;
	import away3d.materials.*;
	import away3d.materials.passes.*;

	import away3d.modifiers.gpu.ModifierBase;
	import away3d.animators.nodes.ModifierClipNode;
	import away3d.animators.states.ModifierAnimationState;
	
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix;
	
	use namespace arcane;
	
	/**
	 * Provides an interface for assigning vertex based animation using modifiers
	 */
	public class ModifierAnimator extends AnimatorBase implements IAnimator
	{
		private var _modifier:ModifierBase;
		
		/**
		 * Creates a new <code>ModifierAnimator</code> object.
		 *
		 * @param modifierBase The modifier for the animator.
		 */
		public function ModifierAnimator(modifierBase:ModifierBase)
		{
			_modifier = modifierBase;
			super(_modifier);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{
			var subMesh:SubMesh = renderable as SubMesh;
			if(subMesh) _modifier.updateRenderState(stage3DProxy, subMesh, vertexConstantOffset, vertexStreamOffset, camera);
		}
		
		/**
		 * None of the parameters is used in thsi animator. Refer to the specific modifier doc.
		 */
		public function play(name:String, transition:IAnimationTransition = null, offset:Number = NaN):void
		{
			transition = transition;
			offset = offset;
			name = name;

			if(!_activeNode){ _activeNode = new ModifierClipNode();}
			
			//_activeAnimationName = name;
			//_activeState = getAnimationState(_activeNode);
			
			start();
		}

		override protected function updateDeltaTime(dt:Number):void{}
		
		/**
		 * Verifies if the animation will be used on cpu. Needs to be true for all passes for a material to be able to use it on gpu.
		 * Needs to be called if gpu code is potentially required.
		 */
		public function testGPUCompatibility(pass:MaterialPassBase):void
		{
			_animationSet.cancelGPUCompatibility();
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IAnimator
		{
			return new ModifierAnimator(_modifier);
		}
	
	}
}
