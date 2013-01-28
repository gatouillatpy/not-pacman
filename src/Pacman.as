package
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Linear;
	
	import flash.display.Sprite;
	
	public class Pacman extends Sprite
	{
		private var _angle : Number;
		private var _radius : Number;
		
		private var _tween : GTween;
		private var _pendingAnimation : Boolean;
		
		public function get angle() : Number
		{
			return _angle;
		}
		
		public function set angle(value : Number) : void
		{
			_angle = value;
			
			refresh();
		}
		
		public function get radius() : Number
		{
			return _radius;
		}
		
		public function set radius(value : Number) : void
		{
			_radius = value;
			
			refresh();
		}
		
		public function Pacman(angle : Number = 0.785, radius : Number = 450)
		{
			super();
			
			_angle = angle;
			_radius = radius;
			
			refresh();
		}
		
		public function dispose() : void
		{
			if(_tween)
			{
				_tween.paused = true;
				_tween = null;
			}
			
			removeChildren();
		}
		
		public function animate() : void
		{
			if(_tween)
			{
				_pendingAnimation = true;
				
				return;
			}
			
			_tween = new GTween(this, 0.1, {angle: 0.0}, {reflect: true, repeatCount: 2, ease: Linear.easeNone, onComplete: tweenCompleteHandler});
		}
		
		public function die() : void
		{
			if(_tween)
				_tween.paused = true;
			
			_tween = new GTween(this, 2.0, {angle: 2.0 * Math.PI}, {ease: Linear.easeNone, onComplete: tweenCompleteHandler});
			
			_pendingAnimation = false;
		}
		
		public function refresh() : void
		{
			var n : int = 80;
			var dw : Number = (2.0 * Math.PI - _angle) / n;
			
			graphics.clear();
			
			if(_angle >= 2.0 * Math.PI) return;
			
			graphics.beginFill(0xFFFF00);
			graphics.moveTo(0.0, 0.0);
			for(var i : int = 0 ; i < n ; i++)
				graphics.lineTo(_radius * Math.cos(Math.PI + 0.5 * _angle + i * dw), _radius * Math.sin(Math.PI + 0.5 * _angle + i * dw));
			graphics.endFill();
		}
		
		private function tweenCompleteHandler(t : GTween) : void
		{
			_tween = null;
			
			if(_pendingAnimation)
			{
				_pendingAnimation = false;
				
				animate();
			}
		}
	}
}