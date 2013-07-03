package away3d.textures {
	import away3d.arcane;
	import away3d.materials.utils.MipmapGenerator;
	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;

	use namespace arcane;

	public class ByteArrayTexture extends Texture2DBase
	{
		private var _byteArray : ByteArray;

		public function ByteArrayTexture(byteArray : ByteArray, width : int, height : int)
		{
			super();

			setByteArray(byteArray, width, height);
		}

		public function get byteArray() : ByteArray
		{
			return _byteArray;
		}

		public function setByteArray(value : ByteArray, width : int, height : int) : void
		{
			if (value == _byteArray) return;

			invalidateContent();
			setSize(width, height);

			_byteArray = value;
			_byteArray.length =  width * height * 4;
		}

		override protected function uploadContent(texture : TextureBase) : void
		{
			Texture(texture).uploadFromByteArray(_byteArray, 0, 0);
		}

		override public function dispose() : void
		{
			super.dispose();
			_byteArray = null;
		}
	}
}
