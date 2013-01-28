package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Keyboard;

	public class Menu implements State
	{
		private var _root : NotPacman;
		
		private var _view : Sprite;
		
		private var _introDelay : Number;
		private var _startTime : Number;
		private var _menuReady : Boolean;
		private var _menuSelection : int;
		
		private var _title : Sprite;
		private var _menu : Text;
		private var _name : Text;
		private var _table : Text;
		private var _clock : Sprite;
		
		private var _namcoText : Text;
		private var _namcoButton : Sprite;
		
		private var _legalA : Text;
		private var _legalB : Text;
		
		public function get view() : Sprite
		{
			return _view;
		}
		
		public function load(root : NotPacman) : void
		{
			_root = root;
			_root.upKey.visible = true;
			_root.downKey.visible = true;
			_root.okKey.visible = true;
			_root.leftKey.visible = false;
			_root.rightKey.visible = false;
			_root.backKey.visible = false;
			_root.speedKey.visible = false;
			
			_introDelay = 3.0;
			_startTime = _root.getTime();
			_menuReady = false;
			
			Assets.stopAllSounds();
			
			_title = Assets.spawnSprite(Assets.Title, true, false, 0, 0, _root.scale);
			_menu = new Text(Assets.Font, Assets.CharList, false);
			_name = new Text(Assets.Font, Assets.CharList, false);
			_table = new Text(Assets.Font, Assets.CharList, false);
			_clock = Assets.spawnSprite(Assets.Clock, true, false, 0, 0, _root.scale);
			
			var gn : String = _root.bestRecord.name;
			var gs : String = "°" + addZeros(_root.bestRecord.score.toString(), 5);
			var gt : String = _root.bestRecord.time.toFixed(1);
			
			_name.print(gn, 0.0, 35 * _root.scale, _root.scale, 1.0, 1.0, 1.0);
			_name.x = (_root.screenWidth - _name.width) / 2;
			
			_table.print(gs, 0, 45 * _root.scale, _root.scale, 1.0, 1.0, 0.0);
			_table.print(gt, 65 * _root.scale, 45 * _root.scale, _root.scale, 0.5, 0.5, 0.5);
			_table.x = (_root.screenWidth - _table.width) / 2;
			_clock.x = _table.x + 55 * _root.scale;
			
			_namcoText = new Text(Assets.Font, Assets.CharList, false);
			_namcoButton = Assets.spawnSprite(Assets.NamcoButton, true, false, 0, 0, 0.6 * _root.scale);
			
			_namcoText.print("play the real pacman game", 0.0, 0.0, _root.scale, 1.0, 1.0, 1.0);
			_namcoText.x = (_root.screenWidth - _namcoText.width - _namcoButton.width - 8 * _root.scale) / 2;
			_namcoText.y = -999;
			
			_namcoButton.x = _namcoText.x + _namcoText.width + 8 * _root.scale;
			_namcoButton.y = -999;
			_namcoButton.addEventListener(MouseEvent.MOUSE_DOWN, namcoButtonHander);
			_namcoButton.buttonMode = true;
			
			_legalA = new Text(Assets.Font, Assets.CharList, false);
			_legalA.print("based on original ideas by", 0.0, 0.0, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			_legalA.x = (_root.screenWidth - _legalA.width) / 2;
			_legalA.y = -999;
			
			_legalB = new Text(Assets.Font, Assets.CharList, false);
			_legalB.print("namco and stabyourself.net", 0.0, 0.0, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			_legalB.x = (_root.screenWidth - _legalB.width) / 2;
			_legalB.y = -999;
			
			_view = new Sprite();
			_view.addChild(_title);
			_view.addChild(_menu);
			_view.addChild(_name);
			_view.addChild(_table);
			_view.addChild(_clock);
			_view.addChild(_namcoButton);
			_view.addChild(_namcoText);
			_view.addChild(_legalA);
			_view.addChild(_legalB);
			
			select(0);
		}
		
		private function namcoButtonHander(e : MouseEvent) : void
		{
			if(_root.isAND)
				navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=com.NamcoNetworks.international.PacMan"));
			else
				navigateToURL(new URLRequest("https://itunes.apple.com/us/app/pac-man/id281656475?mt=8"));
		}
		
		public function unload() : void
		{
			if(_namcoButton)
			{
				Assets.releaseSprite(_namcoButton);
				_namcoButton = null;
			}
			
			if(_namcoText)
			{
				_namcoText.dispose();
				_namcoText = null;
			}
			
			if(_legalA)
			{
				_legalA.dispose();
				_legalA = null;
			}
			
			if(_legalB)
			{
				_legalB.dispose();
				_legalB = null;
			}
			
			if(_clock)
			{
				Assets.releaseSprite(_clock);
				_clock = null;
			}
			
			if(_table)
			{
				_table.dispose();
				_table = null;
			}
			
			if(_name)
			{
				_name.dispose();
				_name = null;
			}
			
			if(_menu)
			{
				_menu.dispose();
				_menu = null;
			}
			
			if(_title)
			{
				Assets.releaseSprite(_title);
				_title = null;
			}
			
			if(_view)
			{
				_view.removeChildren();
				_view = null;
			}
			
			_root = null;
		}
		
		private function addZeros(s : String, i : int) : String
		{
			for(var j : int = s.length + 1 ; j <= i ; j++)
				s = "0" + s;
			
			return s;
		}
		
		private function select(i : int) : void
		{
			_menuSelection = i;
			
			_menu.clear();
			
			if(_menuSelection == 0)
			{
				_menu.print("> play",  -48 * _root.scale, 154 * _root.scale, _root.scale, 1.0, 1.0, 1.0);
				_menu.print("options", -31 * _root.scale, 170 * _root.scale, _root.scale, 0.4, 0.4, 0.4);
				_menu.print("leaderboard", -31 * _root.scale, 186 * _root.scale, _root.scale, 0.4, 0.4, 0.4);
			}
			else if(_menuSelection == 1)
			{
				_menu.print("play",  -31 * _root.scale, 154 * _root.scale, _root.scale, 0.4, 0.4, 0.4);
				_menu.print("> options", -48 * _root.scale, 170 * _root.scale, _root.scale, 1.0, 1.0, 1.0);
				_menu.print("leaderboard", -31 * _root.scale, 186 * _root.scale, _root.scale, 0.4, 0.4, 0.4);
			}
			else if(_menuSelection == 2)
			{
				_menu.print("play",  -31 * _root.scale, 154 * _root.scale, _root.scale, 0.4, 0.4, 0.4);
				_menu.print("options", -31 * _root.scale, 170 * _root.scale, _root.scale, 0.4, 0.4, 0.4);
				_menu.print("> leaderboard", -48 * _root.scale, 186 * _root.scale, _root.scale, 1.0, 1.0, 1.0);
			}
		}
		
		public function update(dt : Number) : void
		{
			if(_menuReady == false)
			{
				if(_root.getTime() - _startTime > _introDelay)
					_menuReady = true;
			}
		}
		
		public function draw() : void
		{
			var yOffset : Number;
			if(_menuReady == false)
				yOffset = Math.floor(250 * _root.scale - 250 * ((_root.getTime() - _startTime) / _introDelay) * _root.scale);
			else
				yOffset = 0.0;
			
			_title.x = _root.screenWidth / 2 - 150 * _root.scale;
			_title.y = _root.screenHeight / 2 - 150 * _root.scale + yOffset;
			
			_menu.x = _root.screenWidth / 2;
			_menu.y = yOffset;
			
			_name.y = yOffset;
			_table.y = yOffset;
			_clock.y = 45 * _root.scale + yOffset;
			
			_namcoText.y = _root.screenHeight - _namcoText.height - 14 * _root.scale + yOffset;
			_namcoButton.y = _root.screenHeight - _namcoButton.height - 8 + yOffset;
			
			_legalA.y = 120 * _root.scale + yOffset;
			_legalB.y = _legalA.y + _legalA.height + 4 * _root.scale;
		}
		
		public function keyDownHandler(keyCode : int, charCode : int) : void
		{
			if(keyCode == Keyboard.ESCAPE)
				NativeApplication.nativeApplication.exit(0);
			
			if(_menuReady == false)
			{
				_menuReady = true;
			}
			else if(keyCode == Keyboard.ENTER)
			{
				if(_menuSelection == 0)
					_root.setState("game");
				else if(_menuSelection == 1)
					_root.setState("setup");
				else
					_root.setState("leaderboard");
			}
			else if(keyCode == Keyboard.UP || keyCode == Keyboard.DOWN)
			{
				if(_menuSelection == 0)
					select(1);
				else if(_menuSelection == 1)
					select(2);
				else
					select(0);
			}
		}
		
		public function keyUpHandler(keyCode : int, charCode : int) : void
		{
		}
		
		public function mouseClickHandler(x : Number, y : Number) : void
		{
			if(_menuReady == false)
			{
				_menuReady = true;
			}
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