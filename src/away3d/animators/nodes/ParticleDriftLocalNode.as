package away3d.animators.nodes
{
	import away3d.animators.data.AnimationRegisterCache;
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.states.ParticleDriftLocalState;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.passes.MaterialPassBase;
	import flash.geom.Vector3D;
	/**
	 * ...
	 */
	public class ParticleDriftLocalNode extends LocalParticleNodeBase
	{
		public static const NAME:String = "ParticleDriftLocalNode";
		public static const DRIFT_STREAM_REGISTER:int = 0;
		
		
		public function ParticleDriftLocalNode()
		{
			super(NAME, 0);
			_stateClass = ParticleDriftLocalState;
			_dataLength = 4;
			initOneData();
		}
		
		override public function generatePropertyOfOneParticle(param:ParticleParameter):void
		{
			//(Vector3D.x,Vector3D.y,Vector3D.z) is drift position,Vector3D.w is drift cycle
			var drift:Vector3D = param[NAME];
			if (!drift)
				throw(new Error("there is no " + NAME + " in param!"));
			
			_oneData[0] = drift.x;
			_oneData[1] = drift.y;
			_oneData[2] = drift.z;
			_oneData[3] = Math.PI * 2 / drift.w;
		}
		
		
		override public function getAGALVertexCode(pass:MaterialPassBase, animationRegisterCache:AnimationRegisterCache) : String
		{
			var driftAttribute:ShaderRegisterElement = animationRegisterCache.getFreeVertexAttribute();
			animationRegisterCache.setRegisterIndex(this, DRIFT_STREAM_REGISTER, driftAttribute.index);
			var temp:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			var dgree:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "x");
			var sin:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "y");
			var cos:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "z");
			animationRegisterCache.addVertexTempUsages(temp, 1);
			var temp2:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			var distance:ShaderRegisterElement = new ShaderRegisterElement(temp2.regName, temp2.index, "xyz");
			animationRegisterCache.removeVertexTempUsage(temp);
			
			var code:String = "";
			code += "mul " + dgree + "," + animationRegisterCache.vertexTime + "," + driftAttribute + ".w\n";
			code += "sin " + sin + "," + dgree + "\n";
			code += "mul " + distance + "," + sin + "," + driftAttribute + ".xyz\n";
			code += "add " + animationRegisterCache.positionTarget +"," + distance + "," + animationRegisterCache.positionTarget + "\n";
			
			if (animationRegisterCache.needVelocity)
			{	code += "cos " + cos + "," + dgree + "\n";
				code += "mul " + distance + "," + cos + "," + driftAttribute + ".xyz\n";
				code += "add " + animationRegisterCache.velocityTarget + ".xyz," + distance + "," + animationRegisterCache.velocityTarget + ".xyz\n";
			}
			
			return code;
		}
	}

}