package away3d.modifiers.gpu
{
	import away3d.animators.IAnimationSet;
	import away3d.animators.AnimationSetBase;
	
	import away3d.core.managers.Stage3DProxy;
	import away3d.cameras.Camera3D;
	import away3d.materials.passes.MaterialPassBase;
 
	import away3d.cameras.Camera3D;
	import away3d.core.base.*;
	
	import flash.display3D.Context3D;
	
	/**
	 * ModifierBase is an interface for modifiers.
	 */
	public class ModifierBase extends AnimationSetBase implements IAnimationSet
	{
		private var _agalCode:String;
		
		public function ModifierBase(){
			resetGPUCompatibility();
		}

		public function updateRenderState(stage3DProxy:Stage3DProxy, subMesh:SubMesh, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void{}
		 
		public function getAGALVertexCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>, profile:String):String
		{
			throw new Error("ModifierBase must be extended by a modifier!");
		}
		
		public function deactivate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void
		{
			var context:Context3D = stage3DProxy.context3D;
			context.setVertexBufferAt(0, null);
		}

		public function activate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void{}
		 
		public function getAGALFragmentCode(pass:MaterialPassBase, shadedTarget:String, profile:String):String{return "";}
		 
		public function getAGALUVCode(pass:MaterialPassBase, UVSource:String, UVTarget:String):String{return "";}
		 
		public function doneAGALCode(pass:MaterialPassBase):void{}

		override public function get usesCPU():Boolean{return false;}
		 
	}
}
