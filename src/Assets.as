package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	public class Assets
	{
		public static var CharList : String = "0123456789abcdefghijklmnopqrstuvwxyz.:/,'C-_> <°";
		
		//------------
		//--GRAPHICS--
		//------------
		
		[Embed(source="/graphics/clock.png")]
		public static var Clock : Class;
		
		[Embed(source="/graphics/eyes.png")]
		public static var Eyes : Class;
		
		[Embed(source="/graphics/field.png")]
		public static var Field : Class;
		
		[Embed(source="/graphics/demofield.png")]
		public static var DemoField : Class;
		
		[Embed(source="/graphics/font.png")]
		public static var Font : Class;
		
		[Embed(source="/graphics/gametime.png")]
		public static var GameTime : Class;
		
		[Embed(source="/graphics/gamescore.png")]
		public static var GameScore : Class;
		
		[Embed(source="/graphics/ghost1.png")]
		public static var Ghost1 : Class;
		
		[Embed(source="/graphics/ghost2.png")]
		public static var Ghost2 : Class;
		
		[Embed(source="/graphics/ghost3.png")]
		public static var Ghost3 : Class;
		
		[Embed(source="/graphics/ghostscared1.png")]
		public static var GhostScared1 : Class;
		
		[Embed(source="/graphics/ghostscared2.png")]
		public static var GhostScared2 : Class;
		
		[Embed(source="/graphics/icon.png")]
		public static var Icon : Class;
		
		[Embed(source="/graphics/impulse12.png")]
		public static var Logo : Class;
		
		[Embed(source="/graphics/options.png")]
		public static var Options : Class;
		
		[Embed(source="/graphics/pacmanman.png")]
		public static var PacmanMan : Class;
		
		[Embed(source="/graphics/spinnyeyes.png")]
		public static var SpinnyEyes : Class;
		
		[Embed(source="/graphics/title.png")]
		public static var Title : Class;
		
		[Embed(source="/graphics/up.png")]
		public static var UpKey : Class;
		
		[Embed(source="/graphics/down.png")]
		public static var DownKey : Class;
		
		[Embed(source="/graphics/left.png")]
		public static var LeftKey : Class;
		
		[Embed(source="/graphics/right.png")]
		public static var RightKey : Class;
		
		[Embed(source="/graphics/ok.png")]
		public static var OkKey : Class;
		
		[Embed(source="/graphics/back.png")]
		public static var BackKey : Class;
		
		[Embed(source="/graphics/speed.png")]
		public static var SpeedKey : Class;
		
		[Embed(source="/graphics/leaderboard.png")]
		public static var Leaderboard : Class;
		
		[Embed(source="/graphics/namco.png")]
		public static var NamcoButton : Class;
		
		[Embed(source="/graphics/facebook.png")]
		public static var FacebookButton : Class;
		
		[Embed(source="/graphics/twitter.png")]
		public static var TwitterButton : Class;
		
		//------------
		//---SOUNDS---
		//------------
		
		[Embed(source="/sounds/pacman_beginning.mp3")]
		public static var PacmanBeginning : Class;
		
		[Embed(source="/sounds/pacman_death.mp3")]
		public static var PacmanDeath : Class;
		
		[Embed(source="/sounds/pacman_eatghost.mp3")]
		public static var PacmanEatGhost : Class;
		
		[Embed(source="/sounds/pacman_waka_ka.mp3")]
		public static var PacmanWakaKa : Class;
		
		[Embed(source="/sounds/pacman_waka_wa.mp3")]
		public static var PacmanWakaWa : Class;
		
		[Embed(source="/sounds/pacman_win.mp3")]
		public static var PacmanWin : Class;
		
		//-------------
		//---HELPERS---
		//-------------
		
		public static function spawnSprite(Asset : Class, visible : Boolean = true, smoothing : Boolean = true, originX : int = 0, originY : int = 0, scale : Number = 1.0) : Sprite
		{
			var bitmap : Bitmap;
			bitmap = new Asset() as Bitmap;
			bitmap.smoothing = smoothing;
			bitmap.x = -originX;
			bitmap.y = -originY;
			
			var sprite : Sprite;
			sprite = new Sprite();
			sprite.addChild(bitmap);
			sprite.visible = visible;
			sprite.scaleX = scale;
			sprite.scaleY = scale;
			
			return sprite;
		}
		
		public static function releaseSprite(sprite : Sprite) : void
		{
			if(sprite.numChildren > 0)
			{
				if(sprite.getChildAt(0) is Bitmap)
					(sprite.getChildAt(0) as Bitmap).bitmapData.dispose();
				
				sprite.removeChildren();
			}
			
			if(sprite.parent)
				sprite.parent.removeChild(sprite);
		}
		
		private static var _allChannels : Vector.<SoundChannel> = new Vector.<SoundChannel>();
		
		public static function playSound(Asset : Class, loop : Boolean = false, volume : Number = 1.0) : SoundChannel
		{
			var sound : Sound;
			sound = new Asset() as Sound;
			
			var channel : SoundChannel;
			channel = sound.play(0, loop ? 999999 : 0, new SoundTransform(volume));
			
			_allChannels.push(channel);
			
			return channel;
		}
		
		public static function stopAllSounds() : void
		{
			for(var k : int = 0 ; k < _allChannels.length ; k++)
			{
				_allChannels[k].stop();
			}
			
			_allChannels = new Vector.<SoundChannel>();
		}
	}
}