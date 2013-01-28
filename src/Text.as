package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class Text extends Sprite
	{
		private var _source : Bitmap;
		private var _map : Dictionary;
		
		private var _chars : Vector.<Bitmap>;
		
		public function Text(Asset : Class, list : String, smoothing : Boolean = false, scale : Number = 1.0)
		{
			super();
			
			_source = new Asset() as Bitmap;
			_source.smoothing = smoothing;
			
			_map = new Dictionary();
			
			var x0 : int = 0;
			var x1 : int = 0;
			
			for(var k : int = 0 ; k < list.length ; k++)
			{
				x1++;
				
				for(x0 = x1; ; x1++)
				{
					if(_source.bitmapData.getPixel(x1, 0) == 0xED1C24)
						break;
				}
				
				_map[list.charAt(k)] = new Rectangle(x0, 0, x1 - x0, _source.bitmapData.height);
			}
			
			scaleX = scale;
			scaleY = scale;
			
			clear();
		}
		
		public function dispose() : void
		{
			clear();
			
			_chars = null;
			
			if(_source)
			{
				_source.bitmapData.dispose();
				_source = null;
			}
			
			_map = null;
		}
		
		public function clear() : void
		{
			removeChildren();
			
			if(_chars)
			{
				for(var k : int = 0 ; k < _chars.length ; k++)
				{
					_chars[k].bitmapData.dispose();
				}
			}
			
			_chars = new Vector.<Bitmap>();
		}
		
		public function print(text : String, x : Number, y : Number, scale : Number = 1.0, r : Number = 1.0, g : Number = 1.0, b : Number = 1.0, a : Number = 1.0) : void
		{
			var xOffset : Number = 0.0;
			var yOffset : Number = 0.0;
			
			for(var k : int = 0 ; k < text.length ; k++)
			{
				if(text.charAt(k) == '\n')
				{
					xOffset = 0.0;
					yOffset += scale * (bitmap.bitmapData.height + 3);
				}
				else
				{
					var rect : Rectangle = _map[text.charAt(k)];
					
					var bitmap : Bitmap;
					bitmap = new Bitmap(new BitmapData(rect.width, rect.height, true, 0x00), "auto", _source.smoothing);
					bitmap.bitmapData.copyPixels(_source.bitmapData, rect, new Point());
					bitmap.transform.colorTransform = new ColorTransform(r, g, b, a);
					bitmap.scaleX = scale;
					bitmap.scaleY = scale;
					bitmap.x = x + xOffset;
					bitmap.y = y + yOffset;
					
					_chars.push(bitmap);
					
					addChild(bitmap);
					
					xOffset += scale * (rect.width + 1);
				}
			}
		}
	}
}