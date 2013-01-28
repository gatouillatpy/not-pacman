package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.ui.Keyboard;

	public class Leaderboard implements State
	{
		protected var _root : NotPacman;
		
		protected var _view : Sprite;
		
		protected var _menuSelection : int;
		
		protected var _leaderboard : Sprite;
		protected var _records : Text;
		protected var _menu : Text;
		
		protected var _offset : int;
		protected var _orderby : String;
		
		protected var _socialText : Text;
		protected var _facebookButton : Sprite;
		protected var _twitterButton : Sprite;
		
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
			_root.leftKey.visible = true;
			_root.rightKey.visible = true;
			_root.backKey.visible = true;
			_root.speedKey.visible = false;
			
			_offset = 0;
			_orderby = "score";
			
			Assets.stopAllSounds();
			
			_leaderboard = Assets.spawnSprite(Assets.Leaderboard, true, false, 0, 0, _root.scale);
			_records = new Text(Assets.Font, Assets.CharList, false);
			_menu = new Text(Assets.Font, Assets.CharList, false);
			
			_records.print("rank", 10 * _root.scale, 0, 0.75 * _root.scale, 0.64, 0.0, 0.0);
			_records.print("name", 60 * _root.scale, 0, 0.75 * _root.scale, 0.64, 0.0, 0.0);
			_records.print("score", 160 * _root.scale, 0, 0.75 * _root.scale, 0.64, 0.0, 0.0);
			_records.print("time", 220 * _root.scale, 0, 0.75 * _root.scale, 0.64, 0.0, 0.0);
			
			_socialText = new Text(Assets.Font, Assets.CharList, false);
			_facebookButton = Assets.spawnSprite(Assets.FacebookButton, true, false, 0, 0, 0.6 * _root.scale);
			_twitterButton = Assets.spawnSprite(Assets.TwitterButton, true, false, 0, 0, 0.6 * _root.scale);
			
			_socialText.print("follow impulse12:", 0.0, 0.0, _root.scale, 1.0, 1.0, 1.0);
			_socialText.x = 10 * _root.scale;
			_socialText.y = _root.screenHeight - _socialText.height - 12 * _root.scale;
			
			_facebookButton.x = _socialText.x + _socialText.width + 8 * _root.scale;
			_facebookButton.y = _root.screenHeight - _facebookButton.height - 8;
			_facebookButton.addEventListener(MouseEvent.MOUSE_DOWN, facebookButtonHander);
			_facebookButton.buttonMode = true;
			
			_twitterButton.x = _facebookButton.x + _facebookButton.width + 8 * _root.scale;
			_twitterButton.y = _root.screenHeight - _twitterButton.height - 8;
			_twitterButton.addEventListener(MouseEvent.MOUSE_DOWN, twitterButtonHander);
			_twitterButton.buttonMode = true;
			
			_view = new Sprite();
			_view.addChild(_leaderboard);
			_view.addChild(_records);
			_view.addChild(_menu);
			_view.addChild(_socialText);
			_view.addChild(_facebookButton);
			_view.addChild(_twitterButton);
			
			select(0);
			
			refresh();
		}
		
		private function facebookButtonHander(e : MouseEvent) : void
		{
			navigateToURL(new URLRequest("http://www.facebook.com/pages/Impulse12/389631824460623"));
		}
		
		private function twitterButtonHander(e : MouseEvent) : void
		{
			navigateToURL(new URLRequest("https://twitter.com/impulse12games"));
		}
		
		public function unload() : void
		{
			if(_menu)
			{
				_menu.dispose();
				_menu = null;
			}
			
			if(_records)
			{
				_records.dispose();
				_records = null;
			}
			
			if(_leaderboard)
			{
				Assets.releaseSprite(_leaderboard);
				_leaderboard = null;
			}
			
			if(_view)
			{
				_view.removeChildren();
				_view = null;
			}
			
			_root = null;
		}
		
		protected function select(i : int) : void
		{
			_menuSelection = i;
			
			_menu.clear();
			
			if(_menuSelection == 0)
				_menu.print("< previous 10",  -3 * _root.scale, 131 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("previous 10",  10 * _root.scale, 131 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 1)
				_menu.print("next 10 >",  210 * _root.scale, 131 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("next 10",  210 * _root.scale, 131 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 2)
				_menu.print("< previous 100",  -3 * _root.scale, 142 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("previous 100",  10 * _root.scale, 142 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 3)
				_menu.print("next 100 >",  204 * _root.scale, 142 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("next 100",  204 * _root.scale, 142 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 4)
				_menu.print("< previous 1000",  -3 * _root.scale, 153 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("previous 1000",  10 * _root.scale, 153 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 5)
				_menu.print("next 1000 >",  198 * _root.scale, 153 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("next 1000",  198 * _root.scale, 153 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 6)
				_menu.print("order by score",  10 * _root.scale, 164 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("order by score",  10 * _root.scale, 164 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_menuSelection == 7)
				_menu.print("order by time",  10 * _root.scale, 175 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			else
				_menu.print("order by time",  10 * _root.scale, 175 * _root.scale, 0.75 * _root.scale, 0.4, 0.4, 0.4);
			
			if(_orderby == "score")
				_menu.print(">",  -3 * _root.scale, 164 * _root.scale, 0.75 * _root.scale, 0.99, 0.45, 0.38);
			
			if(_orderby == "time")
				_menu.print(">",  -3 * _root.scale, 175 * _root.scale, 0.75 * _root.scale, 0.99, 0.45, 0.38);
		}
		
		protected function refresh() : void
		{
			var variables : URLVariables;
			variables = new URLVariables();
			variables.orderby = _orderby;
			variables.offset = _offset;
			
			var request : URLRequest;
			request = new URLRequest("http://176.31.106.6/pacman/get_records.php");
			request.method = URLRequestMethod.POST;
			request.data = variables;
			
			var loader : URLLoader;
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, refreshErrorHandler);
			loader.addEventListener(Event.COMPLETE, refreshCompleteHandler);
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.load(request);
		}
		
		protected function refreshErrorHandler(event : IOErrorEvent) : void
		{
			var loader : URLLoader;
			loader = event.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, refreshErrorHandler); 
			loader.removeEventListener(Event.COMPLETE, refreshCompleteHandler); 
		}
		
		protected function refreshCompleteHandler(event : Event) : void
		{
			var loader : URLLoader;
			loader = event.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, refreshErrorHandler); 
			loader.removeEventListener(Event.COMPLETE, refreshCompleteHandler); 
			
			var variables : URLVariables;
			variables = loader.data;
			
			if(variables.retcode == 0)
			{
				_records.clear();
				_records.print("rank", 10 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
				_records.print("name", 90 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
				_records.print("score", 160 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
				_records.print("time", 220 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
				
				for(var i : int = 0 ; i < 10 ; i++)
				{
					_records.print(int(_offset + i + 1).toString(), 20 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
					_records.print(variables["name_"+i], 65 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
					_records.print(variables["score_"+i], 170 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
					_records.print(Number(variables["time_"+i] / 10).toFixed(1), 230 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
				}
			}
		}
		
		public function update(dt : Number) : void
		{
		}
		
		public function draw() : void
		{
			_leaderboard.x = _root.screenWidth / 2 - 40 * _root.scale;
			_leaderboard.y = 8 * _root.scale;
			
			_records.x = 16 * _root.scale;
			_records.y = 32 * _root.scale;
			
			_menu.x = 16 * _root.scale;
			_menu.y = 32 * _root.scale;
		}
		
		public function keyDownHandler(keyCode : int, charCode : int) : void
		{
			if(keyCode == Keyboard.ESCAPE)
			{
				_root.save();
				_root.setState("menu");
				
				return;
			}
			
			if(keyCode == Keyboard.LEFT)
			{
				if(_menuSelection == 1)
					_menuSelection = 0;
				else if(_menuSelection == 3)
					_menuSelection = 2;
				else if(_menuSelection == 5)
					_menuSelection = 4;
			}
			else if(keyCode == Keyboard.RIGHT)
			{
				if(_menuSelection == 0)
					_menuSelection = 1;
				else if(_menuSelection == 2)
					_menuSelection = 3;
				else if(_menuSelection == 4)
					_menuSelection = 5;
			}
			else if(keyCode == Keyboard.UP)
			{
				if(_menuSelection == 0)
					_menuSelection = 7;
				else if(_menuSelection == 1)
					_menuSelection = 5;
				else if(_menuSelection == 2)
					_menuSelection = 0;
				else if(_menuSelection == 3)
					_menuSelection = 1;
				else if(_menuSelection == 4)
					_menuSelection = 2;
				else if(_menuSelection == 5)
					_menuSelection = 3;
				else if(_menuSelection == 6)
					_menuSelection = 4;
				else if(_menuSelection == 7)
					_menuSelection = 6;
			}
			else if(keyCode == Keyboard.DOWN)
			{
				if(_menuSelection == 0)
					_menuSelection = 2;
				else if(_menuSelection == 1)
					_menuSelection = 3;
				else if(_menuSelection == 2)
					_menuSelection = 4;
				else if(_menuSelection == 3)
					_menuSelection = 5;
				else if(_menuSelection == 4)
					_menuSelection = 6;
				else if(_menuSelection == 5)
					_menuSelection = 1;
				else if(_menuSelection == 6)
					_menuSelection = 7;
				else if(_menuSelection == 7)
					_menuSelection = 0;
			}
			else if(keyCode == Keyboard.ENTER)
			{
				if(_menuSelection == 0)
				{
					_offset -= 10;
					if(_offset < 0) _offset = 0;
					
					refresh();
				}
				else if(_menuSelection == 1)
				{
					_offset += 10;
					
					refresh();
				}
				else if(_menuSelection == 2)
				{
					_offset -= 100;
					if(_offset < 0) _offset = 0;
					
					refresh();
				}
				else if(_menuSelection == 3)
				{
					_offset += 100;
					
					refresh();
				}
				else if(_menuSelection == 4)
				{
					_offset -= 1000;
					if(_offset < 0) _offset = 0;
					
					refresh();
				}
				else if(_menuSelection == 5)
				{
					_offset += 1000;
					
					refresh();
				}
				else if(_menuSelection == 6)
				{
					_orderby = "score";
					
					refresh();
				}
				else if(_menuSelection == 7)
				{
					_orderby = "time";
					
					refresh();
				}
			}
			
			select(_menuSelection);
		}
		
		public function keyUpHandler(keyCode : int, charCode : int) : void
		{
		}
		
		public function mouseClickHandler(x : Number, y : Number) : void
		{
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