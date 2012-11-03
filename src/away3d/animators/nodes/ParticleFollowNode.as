package away3d.animators.nodes
{
	import away3d.arcane;
	import away3d.animators.data.AnimationRegisterCache;
	import away3d.animators.data.AnimationSubGeometry;
	import away3d.animators.data.ParticleFollowingItem;
	import away3d.animators.data.ParticleFollowStorage;
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.states.ParticleFollowState;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.passes.MaterialPassBase;
	
	use namespace arcane;
	
	/**
	 * ...
	 */
	public class ParticleFollowNode extends ParticleNodeBase
	{
		/** @private */
		arcane static const FOLLOW_POSITION_INDEX:uint = 0;
		
		/** @private */
		arcane static const FOLLOW_ROTATION_INDEX:uint = 1;
		
		/** @private */
		arcane var _hasPosition:Boolean;
		
		/** @private */
		arcane var _hasRotation:Boolean;
		
		/**
		 * Used to set the color node into local property mode.
		 */
		public static const LOCAL:uint = 1;
						
		/**
		 * Creates a new <code>ParticleColorNode</code>
		 *
		 * @param               mode            Defines whether the mode of operation defaults to acting on local properties of a particle or global properties of the node.
		 * @param    [optional] hasPosition     Defines wehether the individual particle reacts to the position of the target.
		 * @param    [optional] hasRotation     Defines wehether the individual particle reacts to the rotation of the target.
		 */
		public function ParticleFollowNode(mode:uint, hasPosition:Boolean = true, hasRotation:Boolean = true)
		{
			_stateClass = ParticleFollowState;
			
			_hasPosition = hasPosition;
			_hasRotation = hasRotation;
			
			super("ParticleFollowNode" + mode, mode, 0, ParticleAnimationSet.POST_PRIORITY);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function processExtraData(param:ParticleParameter, animationSubGeometry:AnimationSubGeometry, numVertex:int):void
		{
			
			var storage:ParticleFollowStorage = animationSubGeometry.extraStorage[this];
			if (!storage)
			{
				storage = animationSubGeometry.extraStorage[this] = new ParticleFollowStorage;
				if (_hasPosition && _hasRotation)
					storage.initData(animationSubGeometry.numVertices, 6);
				else
					storage.initData(animationSubGeometry.numVertices, 3);
			}
			var item:ParticleFollowingItem = new ParticleFollowingItem();
			item.startTime = param.startTime;
			item.lifeTime = param.sleepDuration + param.duration;
			item.numVertex = numVertex;
			var len:uint = storage.itemList.length;
			if (len > 0)
			{
				var lastItem:ParticleFollowingItem = storage.itemList[len - 1];
				item.startIndex = lastItem.startIndex + lastItem.numVertex;
			}
			storage.itemList.push(item);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getAGALVertexCode(pass:MaterialPassBase, animationRegisterCache:AnimationRegisterCache):String
		{
			var code:String = "";
			if (_hasRotation) {
				var rotationAttribute:ShaderRegisterElement = animationRegisterCache.getFreeVertexAttribute();
				animationRegisterCache.setRegisterIndex(this, FOLLOW_POSITION_INDEX, rotationAttribute.index);
				
				var temp1:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
				animationRegisterCache.addVertexTempUsages(temp1, 1);
				var temp2:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
				animationRegisterCache.addVertexTempUsages(temp2, 1);
				var temp3:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
				
				animationRegisterCache.removeVertexTempUsage(temp1);
				animationRegisterCache.removeVertexTempUsage(temp2);
				
				code += "mov " + temp1 + "," + animationRegisterCache.vertexZeroConst + "\n";
				code += "cos " + temp1 + ".x," + rotationAttribute + ".x\n";
				code += "sin " + temp1 + ".y," + rotationAttribute + ".x\n";
				code += "mov " + temp2 + "," + animationRegisterCache.vertexZeroConst + "\n";
				code += "neg " + temp2 + ".x," + temp1 + ".y\n";
				code += "mov " + temp2 + ".y," + temp1 + ".x\n";
				code += "mov " + temp3 + "," + animationRegisterCache.vertexZeroConst + "\n";
				code += "mov " + temp3 + ".z," + animationRegisterCache.vertexOneConst + "\n";
				code += "m33 " + animationRegisterCache.scaleAndRotateTarget + "," + animationRegisterCache.scaleAndRotateTarget + "," + temp1 + "\n";
				
				code += "mov " + temp1 + "," + animationRegisterCache.vertexZeroConst + "\n";
				code += "mov " + temp1 + ".x," + animationRegisterCache.vertexOneConst + "\n";
				code += "mov " + temp2 + ".x," + animationRegisterCache.vertexZeroConst + "\n";
				code += "cos " + temp2 + ".y," + rotationAttribute + ".y\n";
				code += "sin " + temp2 + ".z," + rotationAttribute + ".y\n";
				code += "mov " + temp3 + "," + animationRegisterCache.vertexZeroConst + "\n";
				code += "neg " + temp3 + ".y," + temp2 + ".z\n";
				code += "mov " + temp3 + ".z," + temp2 + ".y\n";
				code += "m33 " + animationRegisterCache.scaleAndRotateTarget + "," + animationRegisterCache.scaleAndRotateTarget + "," + temp1 + "\n";
				
				code += "cos " + temp1 + ".x," + rotationAttribute + ".z\n";
				code += "sin " + temp1 + ".y," + rotationAttribute + ".z\n";
				code += "mov " + temp1 + ".z," + animationRegisterCache.vertexZeroConst + "\n";
				code += "neg " + temp2 + ".x," + temp1 + ".y\n";
				code += "mov " + temp2 + ".y," + temp1 + ".x\n";
				code += "mov " + temp2 + ".z," + animationRegisterCache.vertexZeroConst + "\n";
				code += "mov " + temp3 + "," + animationRegisterCache.vertexZeroConst + "\n";
				code += "mov " + temp3 + ".z," + animationRegisterCache.vertexOneConst + "\n";
				code += "m33 " + animationRegisterCache.scaleAndRotateTarget + "," + animationRegisterCache.scaleAndRotateTarget + "," + temp1 + "\n";
			}
			
			if (_hasPosition) {
				var offsetAttribute:ShaderRegisterElement = animationRegisterCache.getFreeVertexAttribute();
				animationRegisterCache.setRegisterIndex(this, FOLLOW_POSITION_INDEX, offsetAttribute.index);
				code += "add " + animationRegisterCache.scaleAndRotateTarget + "," + offsetAttribute + "," + animationRegisterCache.scaleAndRotateTarget + "\n";
			}
			
			return code;
		}
	}

}
