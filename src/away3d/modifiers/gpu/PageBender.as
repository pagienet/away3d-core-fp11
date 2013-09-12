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
	import flash.geom.Vector3D;

	use namespace arcane;

	/* class PageBender bends a plane to simulate a page of paper. In the current implementation, the geometry is expected to be on XZ plan
	the vertex x values in object space must be positive.*/
	 
	public class PageBender extends ModifierBase
	{	
		private const DEGREES_TO_RADIANS:Number = Math.PI / 180;
		private const FACTOR_FORCE:int = 60;

		private var _force:Number;
		private var _foldRotation:Number;
		private var _width:Number;
		private var _origin:Number;

		private var  _axisLocation:Vector3D;
		private var  _segStart:Vector3D;
		private var  _segEnd:Vector3D;

		private var _vc0:Vector.<Number>;
		private var _vc4:Vector.<Number>;
		private var _vc8:Vector.<Number>;
		private var _vc12:Vector.<Number>;
		private var _vc16:Vector.<Number>;
		private var _vc20:Vector.<Number>;
		private var _vc24:Vector.<Number>;
		private var _vc28:Vector.<Number>;
		private var _vc32:Vector.<Number>;

		public function PageBender(objectWidth:Number, force:Number = .5, origin:Number = 0, foldRotation:Number = 0){

			_width = objectWidth;
			_force = force;
			_origin = origin;
			_foldRotation = foldRotation;

			var hw:Number = _width *.5;
			_axisLocation = new Vector3D(0.0,0.0,0.0);
			_segStart = new Vector3D(5,0.0,hw);
			_segEnd = new Vector3D(5,0.0,-hw);

			_vc0 = new Vector.<Number>();
			_vc4 = new Vector.<Number>();
			_vc8 = new Vector.<Number>();
			_vc12 = new Vector.<Number>();
			_vc16 = new Vector.<Number>();
			_vc20 = new Vector.<Number>();
			_vc24 = new Vector.<Number>();
			_vc28 = new Vector.<Number>();
			_vc32 = new Vector.<Number>();

			updateConstants();
		}

		override public function updateRenderState(stage3DProxy:Stage3DProxy, subMesh:SubMesh, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{

			var vcOffset:uint = vertexConstantOffset;
			//vc0
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc0);
			
			//vc4
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc4);
			
			//vc8
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc8);
			
			//vc12
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc12);
			
			//vc16
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc16);
			
			//vc20
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc20);
			
			//vc24
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc24);
			
			//vc28
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc28);
			
			//vc32
			vcOffset+=4;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcOffset, _vc32);

		}

		override public function getAGALUVCode(pass:MaterialPassBase, UVSource:String, UVTarget:String):String
		{
			return "mov " + UVTarget + "," + UVSource + "\n";
		}

		override public function getAGALVertexCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>, profile:String):String
		{
			var vt0:String =  targetRegisters[0];
			var idRegister:uint =  uint(targetRegisters.length);

			var vt1:String = findTempReg(targetRegisters);
			targetRegisters.push(vt1);
			var vt2:String = findTempReg(targetRegisters);
			targetRegisters.push(vt2);
			var vt3:String = findTempReg(targetRegisters);
			targetRegisters.push(vt3);
			var vt4:String = findTempReg(targetRegisters);
			
			var vcOffset:uint = pass.numUsedVertexConstants;
			var vc0:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc4:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc8:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc12:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc16:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc20:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc24:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc28:String = "vc" + vcOffset;
			vcOffset += 4;
			var vc32:String = "vc" + vcOffset;

	  		var agalCode:String = "";
	  			agalCode += "mov " + vt0 + ", " + sourceRegisters[0] + "\n";
	  			agalCode += "mov v0, va1 \n";

			agalCode +=
			//			x,y,z = the buffer va0 expressed as var "vt0"  
 
			//3				var vt1y:Number = -z;
						"neg "+vt1+".y, "+vt0+".z \n"+

			//4				var vt1x:Number = vc4w * vt1y;
						"mul "+vt1+".x, "+vc4+".w, "+vt1+".y \n"+

			//5				vt1x -= vc8z;
						"sub "+vt1+".x, "+vt1+".x, "+vc8+".z \n"+

			//6				var vt3z:Number = z * vc12w;
						"mul "+vt3+".z, "+vt0+".z, "+vc12+".w \n"+

			//7				//neg vt3z vt3z 
						"neg "+vt3+".z, "+vt3+".z \n"+

			//8				var vt3x:Number = vc4w * vt3z;
						"mul "+vt3+".x, "+vc4+".w, "+ vt3+".z \n"+

			//9				var vt3y:Number = vc20x - vt3x;
						"sub "+vt3+".y, "+vc20+".x, "+vt3+".x \n"+

			//10				vt3y /= vt1x;
						"div "+vt3+".y, "+vt3+".y, "+vt1+".x \n"+

			//11				vt1x = x - vt3y;
						"sub "+vt1+".x, "+vt0+".x, "+vt3+".y \n"+

			//12				vt1x /= vc12w;
						"div "+vt1+".x, "+vt1+".x, "+vc12+".w \n"+
  				
			//13				vt1x = Math.max(vc28w, vt1x);
						"max "+vt1+".x, "+vc28+".w, "+vt1+".x \n"+
  				
			//14				var vt4x:Number = vc16x * vt1x;
						"mul "+vt4+".x, "+vc16+".x, "+ vt1+".x \n"+

		 	//15				var vt4y:Number =  vt4x + vc4x;
		 				"add "+vt4+".y, "+vt4+".x, "+ vc4+".x \n"+

			//16				vt4y *= vc0x;
						"mul "+vt4+".y, "+vt4+".y, "+ vc0+".x \n"+

			//17				x -= vc12x;
						"sub "+vt0+".x, "+vt0+".x, "+vc12+".x \n"+

			//18				y -= vc12y;
						"sub "+vt0+".y, "+vt0+".y, "+vc12+".y \n"+

			//19				z -= vc12z;
						"sub "+vt0+".z, "+vt0+".z, "+vc12+".z \n"+
				
			//20				vt3x = Math.sin(vt4y);
						"sin "+vt3+".x, "+vt4+".y \n"+

			//21				vt3y = vc16w - vt3x;
						"sub "+vt3+".y, "+vc16+".w, "+vt3+".x \n"+

			//22				//negate //neg vt4y vt4y  vt4y = -vt4y;
						"neg "+vt4+".y, "+vt4+".y \n"+

			//23				vt3z = Math.cos(vt4y);
						"cos "+vt3+".z, "+vt4+".y \n"+
				
		//x
			//24				vt1x = vc28x*x;
						"mul "+vt1+".x, "+vc28+".x, "+ vt0+".x \n"+

			//25				vt1y = vc28y*y;
						"mul "+vt1+".y, "+vc28+".y, "+ vt0+".y \n"+

			//26				var vt2x:Number = vc20w - vt1x;
						"sub "+vt2+".x, "+vc20+".w, "+vt1+".x \n"+

			//27				vt2x -= vt1y;
						"sub "+vt2+".x, "+vt2+".x, "+vt1+".y \n"+

			//28				vt1x = vc28z*z;
						"mul "+vt1+".x, "+vc28+".z, "+ vt0+".z \n"+

			//29				vt2x -= vt1x;
						"sub "+vt2+".x, "+vt2+".x, "+vt1+".x \n"+

			//30				vt2x *= vc28x;
						"mul "+vt2+".x, "+vt2+".x, "+ vc28+".x \n"+
  
			//31				vt1x = vc28z * y;
						"mul "+vt1+".x, "+vc28+".z, "+ vt0+".y \n"+

			//32				var vt2y:Number = _vc32z - vt1x;
						"sub "+vt2+".y, "+vc32+".z, "+vt1+".x \n"+

			//33				vt1x = vc28y * z;
						"mul "+vt1+".x, "+vc28+".y, "+ vt0+".z \n"+

			//34				vt2y += vt1x;
						"add "+vt2+".y, "+vt2+".y, "+ vt1+".x \n"+
 
			//35				var vt1z:Number = vc0y - vt2x;
						"sub "+vt1+".z, "+vc0+".y, "+vt2+".x \n"+

			//36				vt1z *= vt3y;
						"mul "+vt1+".z, "+vt1+".z, "+ vt3+".y \n"+
 
			//37				vt1x = vc16z * x;
						"mul "+vt1+".x, "+vc16+".z, "+ vt0+".x \n"+

			//38				vt1x *= vt3x;
						"mul "+vt1+".x, "+vt1+".x, "+ vt3+".x \n"+

			//39				x = vt1z + vt1x;
						"add "+vt0+".x, "+vt1+".z, "+ vt1+".x \n"+

			//40				vt1x = vt2y * vt3z;
						"mul "+vt1+".x, "+vt2+".y, "+ vt3+".z \n"+

			//41				x += vt1x;
						"add "+vt0+".x, "+vt0+".x, "+ vt1+".x \n"+

			//42				x /= vc16z;
						"div "+vt0+".x, "+vt0+".x, "+vc16+".z \n"+


 
		//y
			//43				vt1y = vc28x*x;
						"mul "+vt1+".y, "+vc28+".x, "+ vt0+".x \n"+

			//44				vt1x = vc24z - vt1y;
						"sub "+vt1+".x, "+vc24+".z, "+vt1+".y \n"+

			//45				vt1y =  vc28y*y;
						"mul "+vt1+".y, "+vc28+".y, "+ vt0+".y \n"+

			//46				vt1x -= vt1y;
						"sub "+vt1+".x, "+vt1+".x, "+vt1+".y \n"+

			//47				vt1y =  vc28z*z;
						"mul "+vt1+".y, "+vc28+".z, "+ vt0+".z \n"+

			//48				vt1x -= vt1y;
						"sub "+vt1+".x, "+vt1+".x, "+vt1+".y \n"+

			//49				vt1x *= vc28y;
						"mul "+vt1+".x, "+vt1+".x, "+ vc28+".y \n"+

			//50				vt1x = vc0z - vt1x;
						"sub "+vt1+".x, "+vc0+".z, "+vt1+".x \n"+

			//51				vt1x *= vt3y;
						"mul "+vt1+".x, "+vt1+".x, "+ vt3+".y \n"+

			//52				vt1y = vc16z * y;
						"mul "+vt1+".y, "+vc16+".z, "+ vt0+".y \n"+

			//53				vt1y *= vt3x;
						"mul "+vt1+".y, "+vt1+".y, "+ vt3+".x \n"+

			//54				vt1z = vc28z * x;
						"mul "+vt1+".z, "+vc28+".z, "+ vt0+".x \n"+

			//55				var vt1w:Number = vc24w + vt1z;
						"add "+vt1+".w, "+vc24+".w, "+ vt1+".z \n"+

			//56				vt1z = vc28x * z; 
						"mul "+vt1+".z, "+vc28+".x, "+ vt0+".z \n"+

			//57				vt1w -= vt1z;
						"sub "+vt1+".w, "+vt1+".w, "+vt1+".z \n"+

			//58				vt1w *=vc16y; 
						"mul "+vt1+".w, "+vt1+".w, "+ vc16+".y \n"+

			//59				vt1w *= vt3z;
						"mul "+vt1+".w, "+vt1+".w, "+ vt3+".z \n"+

			//60				y = vt1x+vt1w;
						"add "+vt0+".y, "+vt1+".x, "+ vt1+".w \n"+

			//61				y /= vc16z;
						"div "+vt0+".y, "+vt0+".y, "+vc16+".z \n"+


		//z

			//62				vt1y  = vc28x*x;
						"mul "+vt1+".y, "+vc28+".x, "+ vt0+".x \n"+

			//63				vt1x = vc32x - vt1y;
						"sub "+vt1+".x, "+vc32+".x, "+vt1+".y \n"+

			//64				vt1y  = vc28y*y;
						"mul "+vt1+".y, "+vc28+".y, "+ vt0+".y \n"+

			//65				vt1x -= vt1y;
						"sub "+vt1+".x, "+vt1+".x, "+vt1+".y \n"+

			//66				vt1y  = vc28z*z;
						"mul "+vt1+".y, "+vc28+".z, "+ vt0+".z \n"+

			//67				vt1x -= vt1y;
						"sub "+vt1+".x, "+vt1+".x, "+vt1+".y \n"+

			//68				vt1x *= vc28z;
						"mul "+vt1+".x, "+vt1+".x, "+ vc28+".z \n"+

			//69				vt1w = vc28y * x;
						"mul "+vt1+".w, "+vc28+".y, "+ vt0+".x \n"+

			//70				vt1z = vc32y - vt1w;
						"sub "+vt1+".z, "+vc32+".y, "+vt1+".w \n"+

			//71				vt1w = vc28x * y;
						"mul "+vt1+".w, "+vc28+".x, "+ vt0+".y \n"+

			//72				vt1z += vt1w;
						"add "+vt1+".z, "+vt1+".z, "+ vt1+".w \n"+

			//73				vt1z *= vc16y;
						"mul "+vt1+".z, "+vt1+".z, "+ vc16+".y \n"+

			//74				vt1z *= vt3z;
						"mul "+vt1+".z, "+vt1+".z, "+ vt3+".z \n"+

			//75				vt2x = vc0w - vt1x;
						"sub "+vt2+".x, "+vc0+".w, "+vt1+".x \n"+

			//76				vt2x *= vt3y;
						"mul "+vt2+".x, "+vt2+".x, "+ vt3+".y \n"+

			//77				vt1y = vc16z * z;
						"mul "+vt1+".y, "+vc16+".z, "+ vt0+".z \n"+

			//78				vt1y *= vt3x;
						"mul "+vt1+".y, "+vt1+".y, "+ vt3+".x \n"+

			//79				z = vt2x + vt1y;
						"add "+vt0+".z, "+vt2+".x, "+ vt1+".y \n"+

			//80				z += vt1z;
						"add "+vt0+".z, "+vt0+".z, "+ vt1+".z \n"+

			//90				z /= vc16z;
						"div "+vt0+".z, "+vt0+".z, "+vc16+".z \n"+

			
			//91				x += vc12x;
						"add "+vt0+".x, "+vt0+".x, "+ vc12+".x \n"+

			//92				y += vc12y;
						"add "+vt0+".y, "+vt0+".y, "+ vc12+".y \n"+

			//93				z += vc12z;
						"add "+vt0+".z, "+vt0+".z, "+ vc12+".z \n";
 
			//m44 op, vt0, vc0  define by api in materialPassBase in updateProgram method 

			if( sourceRegisters.length > 1 ){
	  			agalCode += "mov v2, va2 \n";
	  			agalCode += "mov vt2, va1 \n";
	  			agalCode += "mov vt1, va3 \n";
	  		}

			return agalCode;
		}

		private function updateConstants():void
		{
 			var x1:Number;
			var x2:Number;

			if(_foldRotation != 0){
				x1 =  Math.sin( _foldRotation * DEGREES_TO_RADIANS) * _width;
				x2 = -x1;
				x1 += _origin;
				x2 += _origin;

			} else {
				x1 = x2 = _origin;
			}

			if(x1<0) x1 = 0;
			if(x2<0) x2 = 0;

			_segStart.x = x1;
			_segEnd.x = x2;

			_axisLocation.x = (_segStart.x+_segEnd.x)*.5;
			_axisLocation.y = (_segStart.y+_segEnd.y)*.5;
			_axisLocation.z = (_segStart.z+_segEnd.z)*.5;
			
			var a:Number = _segStart.x - _axisLocation.x;
			var b:Number = _segStart.y - _axisLocation.y;
			var c:Number = _segStart.z - _axisLocation.z;
			
			var u:Number = _segEnd.x - _axisLocation.x;
			var v:Number = _segEnd.y - _axisLocation.y;
			var w:Number = _segEnd.z - _axisLocation.z;
  
			var u2:Number = u*u;
			var v2:Number = v*v;
			var w2:Number = w*w;

			_vc0[0] = Math.PI / 180;
			_vc0[1] = a*(v2 + w2);
			_vc0[2] = b*(u2 + w2);
			_vc0[3] = c*(u2 + v2);

			_vc4[0] = 90;
			_vc4[1] = _segStart.x;
			_vc4[2] = _segEnd.x;
			_vc4[3] = _segStart.x - _segEnd.x;

			_vc8[0] = _segStart.z;
			_vc8[1] = _segEnd.z;
			_vc8[2] = (_segStart.z - _segEnd.z) * -_width;
			_vc8[3] = -_width;
 
			_vc12[0] = _axisLocation.x;
			_vc12[1] = _axisLocation.y;
			_vc12[2] = _axisLocation.z;
			_vc12[3] = _width;

			_vc16[0] = _force;
			var ms:Number = Math.sqrt(u * u + v * v + w * w);
			_vc16[1] = ms;
			_vc16[2] = ms*ms;
			_vc16[3] = 1;

			_vc20[0] = ( (_vc4[1]*_vc8[1]) - (_vc8[0]*_vc4[2]) ) * _vc8[3];
			var bv:Number = b*v;
			var cw:Number = c*w;
			_vc20[1] = bv;
			_vc20[2] = cw;
			_vc20[3] = bv+cw;

			var au:Number = a*u;
			var bw:Number = b*w;
			_vc24[0] = au;
			_vc24[1] = (-c *v) + ( bw );
			_vc24[2] = au + cw;
			_vc24[3] = ( c*u) - (a*w);
 
			_vc28[0] = u;
			_vc28[1] = v;
			_vc28[2] = w;
			_vc28[3] = 0;
 
			_vc32[0] = au + bv;
			_vc32[1] = (b*u) + (a*v);
			_vc32[2] = bw;
			_vc32[3] = 0;
		}
  
		 
		public function set force(value:Number):void
		{
			value *= FACTOR_FORCE;
			if(_force != value) {
				_force = value; 
				updateConstants();
			}
		}		
		public function get force():Number
		{
			return _force;
		}
		 
		public function get foldRotation():Number
		{
			return _foldRotation;
		}
		public function set foldRotation(value:Number):void
		{
			if(_foldRotation != value) {
				_foldRotation = value;
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
				if(_origin<1) _origin = 1;

				updateConstants();
			}
		}

		public function clear():void
		{
			_vc0 =  _vc4 =  _vc8 =  _vc12 =  _vc16 = _vc20 = _vc24 = _vc28 = _vc32 = null;
			_axisLocation = _segStart = _segEnd = null;
		}
 
	}
}
