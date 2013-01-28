package
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweenTimeline;
	import com.gskinner.motion.easing.Cubic;
	import com.gskinner.motion.easing.Linear;
	
	import flash.display.Sprite;

	public class Intro implements State
	{
		private var _root : NotPacman;
		
		private var _view : Sprite;
		
		private var _logo : Sprite;
		
		private var _tween : GTweenTimeline;
		
		public function get view() : Sprite
		{
			return _view;
		}
		
		public function load(root : NotPacman) : void
		{
			_root = root;
			
			_logo = Assets.spawnSprite(Assets.Logo, true, true, 188, 293, 0.35 * _root.scale);
			_logo.x = _root.screenWidth / 2;
			_logo.y = _root.screenHeight / 2;
			_logo.alpha = 0.0;
			
			_tween = new GTweenTimeline();
			_tween.addTween(0.0, new GTween(_logo, 0.5, {alpha: 1.0}, {ease: Cubic.easeIn}));
			_tween.addTween(2.0, new GTween(_logo, 0.5, {alpha: 0.0}, {ease: Cubic.easeOut}));
			_tween.addCallback(2.5, tweenCompleteHandler);
			_tween.calculateDuration();
			
			_view = new Sprite();
			_view.addChild(_logo);
		}
		
		public function unload() : void
		{
			if(_logo)
			{
				Assets.releaseSprite(_logo);
				_logo = null;
			}
			
			if(_view)
			{
				_view.removeChildren();
				_view = null;
			}
			
			if(_tween)
			{
				_tween.paused = true;
				_tween = null;
			}
			
			_root = null;
		}
		
		public function update(dt : Number) : void
		{
		}
		
		public function draw() : void
		{
		}
		
		private function tweenCompleteHandler() : void
		{
			_root.setState("menu");
		}
		
		public function keyDownHandler(keyCode : int, charCode : int) : void
		{
			_root.setState("menu");
		}
		
		public function keyUpHandler(keyCode : int, charCode : int) : void
		{
		}
		
		public function mouseClickHandler(x : Number, y : Number) : void
		{
			_root.setState("menu");
		}
		
		public function mouseMoveHandler(x : Number, y : Number) : void
		{
		}
		
		public function mouseDownHandler(x : Number, y : Number) : void
		{
		}
		
		public function mouseUpHandler(x : Number, y : Number) : void
		{
		}
		
		public function gyroscopeUpdateHandler(x : Number, y : Number, z : Number) : void
		{
		}
	}
}