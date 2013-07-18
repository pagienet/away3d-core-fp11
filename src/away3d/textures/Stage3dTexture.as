package away3d.textures
{

	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;

	public class Stage3dTexture extends Texture2DBase
	{
		private var _texture:Texture;

		public function Stage3dTexture() {
			super();
		}

		public function set texture( value:Texture ):void {
			_texture = value;
		}

		override protected function createTexture( context:Context3D ):TextureBase {
			return _texture;
		}

		override protected function uploadContent( texture:TextureBase ):void {
			// Just to avoid abstract method error.
		}
	}
}
