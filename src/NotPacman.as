package
{
	import Box2DAS.Common.b2Base;
	
	import com.adobe.nativeExtensions.Gyroscope;
	import com.adobe.nativeExtensions.GyroscopeEvent;
	
	import de.ketzler.nativeextension.EulerGyroscope;
	import de.ketzler.nativeextension.EulerGyroscopeEvent;
	
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	[SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768", quality="LOW")]
	public class NotPacman extends Sprite
	{
		public static const FRAMERATE : Number = 60;
		
		public var isAND : Boolean;
		public var isIOS : Boolean;
		public var isMobile : Boolean;
		
		public var reverseInput : Boolean;
		
		private var _andGyroscope : Gyroscope;
		private var _iosGyroscope : EulerGyroscope;
		
		private var _time : int;
		
		private var _stateList : Dictionary;
		
		private var _currentState : State;
		
		private var _gyroX : Number = 0.0;
		private var _gyroY : Number = 0.0;
		private var _gyroZ : Number = 0.0;
		
		public var controlMethods : Array;
		public var controlDescriptions : Dictionary;
		public var controlMethod : String;
		
		public var screenWidth : Number;
		public var screenHeight : Number;
		
		public var scale : Number;
		
		public var upKey : Sprite;
		public var downKey : Sprite;
		public var okKey : Sprite;
		public var leftKey : Sprite;
		public var rightKey : Sprite;
		public var backKey : Sprite;
		public var speedKey : Sprite;
		
		public var tempRecord : Record;
		public var bestRecord : Record;
		
		public function NotPacman()
		{
			super();
			
			if(stage)
				setTimeout(init, 1000);
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init() : void
		{
			//------------
			//--SETTINGS--
			//------------
			
			b2Base.initialize();
			
			stage.frameRate = FRAMERATE;
			stage.quality = StageQuality.LOW;
			
			reverseInput = false;
			
			var osInfo : String = Capabilities.version.split(' ')[0];
			
			isAND = (osInfo == 'AND');
			isIOS = (osInfo == 'IOS');
			
			if(isAND || isIOS)
				isMobile = true;
			else
				isMobile = false;
			
			if(isAND)
			{
				if(Gyroscope.isSupported)
				{
					controlMethods = ["planar gyroscope", "wheel gyroscope", "virtual pad", "touch screen"];
					
					_andGyroscope = new Gyroscope();
					_andGyroscope.setRequestedUpdateInterval(1000 / NotPacman.FRAMERATE);
					_andGyroscope.addEventListener(GyroscopeEvent.UPDATE, andGyroscopeUpdateHandler);
				}
				else
				{
					controlMethods = ["virtual pad", "touch screen"];
				}
			}
			else if(isIOS)
			{
				if(EulerGyroscope.isSupported)
				{
					controlMethods = ["planar gyroscope", "wheel gyroscope", "virtual pad", "touch screen"];
					
					_iosGyroscope = new EulerGyroscope();
					_iosGyroscope.setRequestedUpdateInterval(1000 / NotPacman.FRAMERATE);
					_iosGyroscope.addEventListener(EulerGyroscopeEvent.UPDATE, iosGyroscopeUpdateHandler);
				}
				else
				{
					controlMethods = ["virtual pad", "touch screen"];
				}
			}

			else
			{
				controlMethods = ["keyboard", "mouse"];
			}
				
			controlDescriptions = new Dictionary();
			controlDescriptions["keyboard"] = "use arrow keys to\nrotate, shift to\nspeed up";
			controlDescriptions["mouse"] = "point with your\nmouse towards a\ndirection";
			controlDescriptions["wheel gyroscope"] = "rotate your device like\na wheel and let the\ngravity do its work";
			controlDescriptions["planar gyroscope"] = "tilt your device like\na plate and let the\ngravity do its work";
			controlDescriptions["virtual pad"] = "use arrow keys on\nscreen to rotate,\ns to speed up";
			controlDescriptions["touch screen"] = "point with your finger\ntowards a direction";
			
			if(isAND)
			{
				controlDescriptions["wheel gyroscope"] += "\n\nhit the screen to set\nthe reference position";
				controlDescriptions["planar gyroscope"] += "\n\nhit the screen to set\nthe reference position";
			}
			
			//----END----
			
			load();
			
			screenWidth = stage.stageWidth;
			screenHeight = stage.stageHeight;
			
			scale = stage.stageHeight / 250;
			
			//--ONSCREEN BUTTONS--
			
			downKey = Assets.spawnSprite(Assets.DownKey, false, false, 0, 0, 0.6 * scale);
			downKey.x = screenWidth - downKey.width - 8;
			downKey.y = 0.5 * (screenHeight - downKey.height);
			downKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			downKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			downKey.buttonMode = true;
			
			upKey = Assets.spawnSprite(Assets.UpKey, false, false, 0, 0, 0.6 * scale);
			upKey.x = downKey.x;
			upKey.y = downKey.y - upKey.height - 8;
			upKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			upKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			upKey.buttonMode = true;
			
			okKey = Assets.spawnSprite(Assets.OkKey, false, false, 0, 0, 0.6 * scale);
			okKey.x = downKey.x;
			okKey.y = downKey.y + downKey.height + 8;
			okKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			okKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			okKey.buttonMode = true;
			
			rightKey = Assets.spawnSprite(Assets.RightKey, false, false, 0, 0, 0.6 * scale);
			rightKey.x = screenWidth - rightKey.width - 8;
			rightKey.y = screenHeight - rightKey.height - 8;
			rightKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			rightKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			rightKey.buttonMode = true;
			
			leftKey = Assets.spawnSprite(Assets.LeftKey, false, false, 0, 0, 0.6 * scale);
			leftKey.x = rightKey.x - leftKey.width - 8;
			leftKey.y = rightKey.y;
			leftKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			leftKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			leftKey.buttonMode = true;
			
			backKey = Assets.spawnSprite(Assets.BackKey, false, false, 0, 0, 0.6 * scale);
			backKey.x = screenWidth - backKey.width - 8;
			backKey.y = 8;
			backKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			backKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			backKey.buttonMode = true;
			
			speedKey = Assets.spawnSprite(Assets.SpeedKey, false, false, 0, 0, 0.6 * scale);
			speedKey.x = 8;
			speedKey.y = screenHeight - speedKey.height - 8;
			speedKey.addEventListener(MouseEvent.MOUSE_DOWN, virtualKeyDownHander);
			speedKey.addEventListener(MouseEvent.MOUSE_UP, virtualKeyUpHander);
			speedKey.buttonMode = true;
			
			if(isMobile)
			{
				addChild(upKey);
				addChild(downKey);
				addChild(okKey);
				addChild(leftKey);
				addChild(rightKey);
				addChild(backKey);
				addChild(speedKey);
			}
			
			//--STATES--
			
			_stateList = new Dictionary();
			_stateList["intro"] = new Intro();
			_stateList["menu"] = new Menu();
			_stateList["setup"] = new Setup();
			_stateList["game"] = new Game();
			_stateList["leaderboard"] = new Leaderboard();
			_stateList["result"] = new Result();
			
			setState("menu");
			
			//--EVENTS--
			
			_time = getTimer();
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function enterFrameHandler(event : Event) : void
		{
			var t : Number = getTimer();
			var dt : Number = (t - _time) / 1000;
			
			dt = Math.min(dt, 1 / FRAMERATE);
			
			_currentState.update(dt);
			_currentState.draw();
			
			_time = t;
		}
		
		public function getTime() : Number
		{
			return _time / 1000;
		}
		
		public function setState(name : String) : void
		{
			if(_currentState)
				_currentState.unload();
			
			_currentState = _stateList[name];
			_currentState.load(this);
			
			removeChildren();
			addChild(_currentState.view);
			
			if(isMobile)
			{
				addChild(upKey);
				addChild(downKey);
				addChild(okKey);
				addChild(leftKey);
				addChild(rightKey);
				addChild(backKey);
				addChild(speedKey);
			}
		}
		
		private function virtualKeyDownHander(e : MouseEvent) : void
		{
			if(e.currentTarget == upKey)
				_currentState.keyDownHandler(38, 0);
			else if(e.currentTarget == downKey)
				_currentState.keyDownHandler(40, 0);
			else if(e.currentTarget == leftKey)
				_currentState.keyDownHandler(37, 0);
			else if(e.currentTarget == rightKey)
				_currentState.keyDownHandler(39, 0);
			else if(e.currentTarget == okKey)
				_currentState.keyDownHandler(13, 13);
			else if(e.currentTarget == backKey)
				_currentState.keyDownHandler(27, 27);
			else if(e.currentTarget == speedKey)
				_currentState.keyDownHandler(16, 0);
		}
		
		private function virtualKeyUpHander(e : MouseEvent) : void
		{
			if(e.currentTarget == upKey)
				_currentState.keyUpHandler(38, 0);
			else if(e.currentTarget == downKey)
				_currentState.keyUpHandler(40, 0);
			else if(e.currentTarget == leftKey)
				_currentState.keyUpHandler(37, 0);
			else if(e.currentTarget == rightKey)
				_currentState.keyUpHandler(39, 0);
			else if(e.currentTarget == okKey)
				_currentState.keyUpHandler(13, 13);
			else if(e.currentTarget == backKey)
				_currentState.keyUpHandler(27, 27);
			else if(e.currentTarget == speedKey)
				_currentState.keyUpHandler(16, 0);
		}
		
		private function keyDownHandler(e : KeyboardEvent) : void
		{
			_currentState.keyDownHandler(e.keyCode, e.charCode);
		}
		
		private function keyUpHandler(e : KeyboardEvent) : void
		{
			_currentState.keyUpHandler(e.keyCode, e.charCode);
		}
		
		private function mouseClickHandler(e : MouseEvent) : void
		{
			_currentState.mouseClickHandler(e.stageX, e.stageY);
			
			_gyroX = 0.0;
			_gyroY = 0.0;
			_gyroZ = 0.0;
		}
		
		private function mouseMoveHandler(e : MouseEvent) : void
		{
			_currentState.mouseMoveHandler(e.stageX, e.stageY);
		}
		
		private function mouseDownHandler(e : MouseEvent) : void
		{
			_currentState.mouseDownHandler(e.stageX, e.stageY);
		}
		
		private function mouseUpHandler(e : MouseEvent) : void
		{
			_currentState.mouseUpHandler(e.stageX, e.stageY);
		}
		
		private function andGyroscopeUpdateHandler(e : GyroscopeEvent) : void
		{   
			var update : Boolean = false;
			
			if(Math.abs(e.x) > 0.0001)
			{
				if(reverseInput)
					_gyroX -= e.x;
				else
					_gyroX += e.x;
				update = true;
			}
			
			if(Math.abs(e.y) > 0.0001)
			{
				if(reverseInput)
					_gyroY -= e.x;
				else
					_gyroY += e.x;
				update = true;
			}
			
			if(Math.abs(e.z) > 0.0001)
			{
				if(reverseInput)
					_gyroZ -= e.x;
				else
					_gyroZ += e.x;
				update = true;
			}
			
			if(update)
				_currentState.gyroscopeUpdateHandler(_gyroX, _gyroY, _gyroZ);
		}
		
		private function iosGyroscopeUpdateHandler(e : EulerGyroscopeEvent) : void
		{
			if(reverseInput)
			{
				_gyroX = +28.648 * e.pitch;
				_gyroY = +28.648 * e.roll;
				_gyroZ = -28.648 * e.pitch;
			}
			else
			{
				_gyroX = -28.648 * e.pitch;
				_gyroY = -28.648 * e.roll;
				_gyroZ = +28.648 * e.pitch;
			}
			
			_currentState.gyroscopeUpdateHandler(_gyroX, _gyroY, _gyroZ);
		}
				
		public function load() : void
		{
			var so : SharedObject = SharedObject.getLocal("NotPacMan");
			
			controlMethod = controlMethods[0];
			
			if(so.data["controlmethod"])
			{
				for(var i : int = 0 ; i < controlMethods.length ; i++)
				{
					if(so.data["controlmethod"] == controlMethods[i])
						controlMethod = controlMethods[i];
				}
				
				bestRecord = new Record();
				bestRecord.name = so.data["record_name"];
				bestRecord.score = so.data["record_score"];
				bestRecord.time = so.data["record_time"];
				
				if(isNaN(bestRecord.time))
					bestRecord.time = 0;
			}
			else
			{
				bestRecord = new Record();
				bestRecord.name = "------";
				bestRecord.score = 0;
				bestRecord.time = 0;
			}
						
			save();
		}
						
		public function save() : void
		{
			var so : SharedObject = SharedObject.getLocal("NotPacMan");
			
			so.data["controlmethod"] = controlMethod;
			
			if(bestRecord.name)
			{
				so.data["record_name"] = bestRecord.name;
				so.data["record_score"] = bestRecord.score;
				so.data["record_time"] = bestRecord.time;
			}
			else
			{
				so.data["record_name"] = "------";
				so.data["record_score"] = 0;
				so.data["record_time"] = 0;
			}
			
			try
			{
				so.flush( 4096 );
			}
			catch ( error : Error )
			{
			}
		}
	}
}
