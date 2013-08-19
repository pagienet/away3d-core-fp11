package away3d.modifiers.gpu
{
	import away3d.arcane;
	import away3d.modifiers.gpu.ModifierBase;
	import away3d.modifiers.ModifiersConsts;
	import away3d.core.base.SubMesh;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.core.managers.Stage3DProxy;
	import away3d.cameras.Camera3D;
	import away3d.core.base.SubMesh;

	import flash.display3D.Context3DProgramType;

	use namespace arcane;
	 
	public class Bend extends ModifierBase
	{
		private const DOUBLE_PI:Number = Math.PI * 2;
		private const HALF_PI:Number = Math.PI / 2;
		
		private var _force:Number;
		private var _offset:Number;
		private var _width:Number;
		private var _origin:Number;
		
		private var _bendConstants:Vector.<Number>;
		private var _bendConstants2:Vector.<Number>;

		public function Bend(objectWidth:Number, force:Number = 1, origin:Number = 0.5, offset:Number = 0){

			_width = objectWidth;
			_force = force;
			_origin = origin;
			_offset = offset;
			
			_bendConstants = new Vector.<Number>();
			_bendConstants2 = new Vector.<Number>();
			updateConstants();
		}

		override public function updateRenderState(stage3DProxy:Stage3DProxy, subMesh:SubMesh, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{
			//vc0
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset, _bendConstants);
			//vc4
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset+4, _bendConstants2);
		}

		override public function getAGALVertexCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>, profile:String):String
		{

			var idRegister:uint =  uint(targetRegisters[0].substring(2, targetRegisters[0].length) );
			var vt0:String =  "vt"+idRegister;

			idRegister++;
			var vt1:String = "vt"+idRegister;

			idRegister++;
			var vt2:String = "vt"+idRegister;

			idRegister++;
			var vt3:String = "vt"+idRegister;
		 
			var agalCode:String =	"mov "+targetRegisters[0]+", "+sourceRegisters[0]+ " \n" + //mov vt0, va0 

			/*		uvs for fragment shader*/
					"mov v0, va1 \n" +

			/*			x = _originalVertices[i];
						y = _originalVertices[i+1];  //vt0 */

			/*			p = x - _origin;*/
					"sub "+vt1+".x, "+vt0+".x, vc4.w \n"+
			/*			p /= _width;*/
					"div "+vt1+".x, "+vt1+".x, vc4.x \n"+
			/*			fa = bendAngle * p;*/
					"mul "+vt2+".x, "+vt1+".x, vc4.z \n"+
			/*			fa += HALF_PI;*/
					"add "+vt2+".x, "+vt2+".x, vc8.x \n"+
			/*			rad = radius + y;*/
					"add "+vt2+".y, "+vt0+".y, vc4.y \n"+
			/*			pt = Math.sin(fa);*/
					"sin "+vt2+".z, "+vt2+".x \n"+
			/*			pt *= rad;*/
					"mul "+vt2+".z, "+vt2+".z, "+vt2+".y \n"+
			/*			y = pt - radius;*/
					"sub "+vt3+".y, "+vt2+".z, vc4.y \n"+
			/*			ow = Math.cos(fa);*/
					"cos "+vt2+".w, "+vt2+".x \n"+
			/*			ow *= rad;*/
					"mul "+vt2+".w, "+vt2+".w, "+vt2+".y \n"+

			/*			x = _origin/_width;*/
					"mov "+vt3+".x, vc8.z \n"+

			/*			x *= _width;*/
					"mul "+vt3+".x, "+vt3+".x, vc4.x \n"+
			/*			x -= ow;*/
					"sub "+vt3+".x, "+vt3+".x, "+vt2+".w \n"+

 				 
			/*		//sge t a b - If a is greater or equal to b put 1 in t, otherwise put 0 in t.
			 		var sge:Number = (x>_origin)? 1 : 0;*/
			 		"sge "+vt3+".z, "+vt3+".x, vc4.w \n"+
			 
 			/*			x -= _originalVertices[i];*/
 					"sub "+vt3+".x, "+vt3+".x, "+vt0+".x \n"+
 			/*			y -= _originalVertices[+1];*/
 					"sub "+vt3+".y, "+vt3+".y, "+vt0+".y \n"+
			/*			vertices[i] = x * sge;*/
					"mul "+vt0+".x, "+vt3+".x, "+vt3+".z \n"+
			/*			vertices[i] += _originalVertices[i];*/
					"add "+vt0+".x, "+vt0+".x, "+sourceRegisters[0]+".x \n"+
 
			/*			vertices[i+1] = y * sge;*/
					"mul "+vt0+".y, "+vt3+".y, "+vt3+".z \n"+

			/*			vertices[i+1] += _originalVertices[i+1];*/
					"add "+vt0+".y, "+vt0+".y, "+sourceRegisters[0]+".y \n"+
 
			//m44 op, vt0, vc0  define by api in materialPassBase in updateProgram method  

			 "";
			return agalCode;
		}
  
		
		private function updateConstants():void
		{
			var radius:Number = _width / Math.PI / _force;
			var bendAngle:Number = DOUBLE_PI * (_width / (radius * DOUBLE_PI));

			_bendConstants[0] = _width;
			_bendConstants[1] = radius;
			_bendConstants[2] = bendAngle;
			_bendConstants[3] = _origin;

			_bendConstants2[0] = HALF_PI;
			_bendConstants2[1] = _offset;
			_bendConstants2[2] = _origin/_width;
			_bendConstants2[3] = 0;
		}
		 
		public function set force(value:Number):void
		{
			if(_force != value) {
				_force = value; 
				updateConstants();
			}
		}		
		public function get force():Number
		{
			return _force;
		}
		 
		public function get offset():Number
		{
			return _offset;
		}
		public function set offset(value:Number):void
		{
			if(_offset != value) {
				_offset = value;
				updateConstants();
			}
		}

		public function get origin():Number
		{
			return _origin;
		}
		public function set origin(value:Number):void
		{
			if(_origin != value) {
				_origin = value;
				updateConstants();
			}
		}
 
	}
}
