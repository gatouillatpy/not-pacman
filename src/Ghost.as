package
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Linear;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	public class Ghost extends Sprite
	{
		private var _normal : Sprite;
		
		private var _scared1 : Sprite;
		private var _scared2 : Sprite;
		
		private var _normalEyes : Sprite;
		private var _spinnyEyes : Sprite;
		
		private var _huntTime : int;
		private var _huntIntervalId : uint;
		
		private var _tween : GTween;
		
		public var alive : Boolean;
		
		public function Ghost(color : int)
		{
			super();
			
			if(color == 1)
				_normal = Assets.spawnSprite(Assets.Ghost1, true, true, 32, 32);
			else if(color == 2)
				_normal = Assets.spawnSprite(Assets.Ghost2, true, true, 32, 32);
			else if(color == 3)
				_normal = Assets.spawnSprite(Assets.Ghost3, true, true, 32, 32);
			
			_scared1 = Assets.spawnSprite(Assets.GhostScared1, false, true, 32, 32);
			_scared2 = Assets.spawnSprite(Assets.GhostScared2, false, true, 32, 32);
			
			_normalEyes = Assets.spawnSprite(Assets.Eyes, true, true, 32, 32);
			//_spinnyEyes = Assets.spawnSprite(Assets.SpinnyEyes, false, true, 18, 8);
			_spinnyEyes = Assets.spawnSprite(Assets.Eyes, false, true, 32, 32);
			
			addChild(_normal);
			addChild(_scared1);
			addChild(_scared2);
			addChild(_normalEyes);
			addChild(_spinnyEyes);
			
			scaleX = 14.4;
			scaleY = 14.4;
			
			alive = true;
		}
		
		public function dispose() : void
		{
			if(_normal)
			{
				Assets.releaseSprite(_normal);
				_normal = null;
			}
			
			if(_scared1)
			{
				Assets.releaseSprite(_scared1);
				_scared1 = null;
			}
			
			if(_scared2)
			{
				Assets.releaseSprite(_scared2);
				_scared2 = null;
			}
			
			if(_normalEyes)
			{
				Assets.releaseSprite(_normalEyes);
				_normalEyes = null;
			}
			
			if(_spinnyEyes)
			{
				Assets.releaseSprite(_spinnyEyes);
				_spinnyEyes = null;
			}
			
			if(_huntIntervalId)
				clearInterval(_huntIntervalId);
			
			removeChildren();
		}
		
		public function die(target : Point) : void
		{
			alive = false;
			
			_tween = new GTween(this, 0.5, {x: target.x, y: target.y}, {ease: Linear.easeNone, onComplete: tweenCompleteHandler});
		}
		
		public function setScared() : void
		{
			_huntTime = getTimer();
			
			_normal.visible = false;
			_normalEyes.visible = false;
			
			refresh();
			
			if(_huntIntervalId)
				clearInterval(_huntIntervalId);
			
			_huntIntervalId = setInterval(refresh, 40);
		}
		
		public function setNormal() : void
		{
			_normal.visible = true;
			_normalEyes.visible = true;
			
			_scared1.visible = false;
			_scared2.visible = false;
			
			if(_huntIntervalId)
				clearInterval(_huntIntervalId);
			
			_huntIntervalId = 0;
		}
		
		public function refresh() : void
		{
			var t : int = getTimer();
			
			if(alive == false)
			{
				_scared1.visible = false;
				_scared2.visible = false;
				
				_spinnyEyes.visible = true;
			}
			else
			{
				_spinnyEyes.visible = false;
				
				if(t - _huntTime < 5000)
				{
					_scared1.visible = true;
					_scared2.visible = false;
				}
				else if(t - _huntTime < 5250)
				{
					_scared1.visible = false;
					_scared2.visible = true;
				}
				else if(t - _huntTime < 5500)
				{
					_scared1.visible = true;
					_scared2.visible = false;
				}
				else if(t - _huntTime < 5750)
				{
					_scared1.visible = false;
					_scared2.visible = true;
				}
				else if(t - _huntTime < 6000)
				{
					_scared1.visible = true;
					_scared2.visible = false;
				}
				else if(t - _huntTime < 6250)
				{
					_scared1.visible = false;
					_scared2.visible = true;
				}
				else if(t - _huntTime < 6500)
				{
					_scared1.visible = true;
					_scared2.visible = false;
				}
				else if(t - _huntTime < 6750)
				{
					_scared1.visible = false;
					_scared2.visible = true;
				}
			}
		}
		
		private function tweenCompleteHandler(t : GTween) : void
		{
			_tween = null;
			
			alive = true;
		}
	}
}