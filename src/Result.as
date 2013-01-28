package
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.ui.Keyboard;

	public class Result extends Leaderboard
	{
		private var _input : Text;
		private var _help : Text;
		
		private var _key : String;
		private var _name : String;
		private var _score : int;
		private var _time : Number;
		
		private var _index : int;
		
		private function generateKey() : String
		{
			var key : String;
			key  = (Math.random() * 0xFFFF).toString(16).toLowerCase();
			key += (Math.random() * 0xFFFF).toString(16).toLowerCase();
			key += (Math.random() * 0xFFFF).toString(16).toLowerCase();
			
			while ( key.length < 8 ) key = "0" + key;
			
			return key;
		}
		
		override public function load(root : NotPacman) : void
		{
			_root = root;
			
			_input = new Text(Assets.Font, Assets.CharList, false);
			_input.x = 16 * _root.scale;
			_input.y = 32 * _root.scale;
			
			_help = new Text(Assets.Font, Assets.CharList, false);
			_help.print("use up and down arrows to modify a letter,\nleft and right arrows to select another one.", 10 * _root.scale, 139 * _root.scale, 0.75 * _root.scale);
			_help.x = 16 * _root.scale;
			_help.y = 50 * _root.scale;
			
			_key = generateKey();
			_name = _root.tempRecord.name;
			_score = _root.tempRecord.score;
			_time = _root.tempRecord.time;
			
			if(_root.bestRecord && _root.bestRecord.name != null && _root.bestRecord.name != "------")
				_name = _root.bestRecord.name;
			
			super.load(root);
			
			_root.okKey.visible = true;
			_root.backKey.visible = false;
			
			_view.addChild(_input);
			_view.addChild(_help);
		}
		
		override protected function select(i : int) : void
		{
			if(_input)
			{
				_menuSelection = i;
				
				_input.clear();
				_input.print("name:" + _name, 10 * _root.scale, 139 * _root.scale, _root.scale, 1.0, 1.0, 1.0);
				_input.print("_",  (50 + _index * 8) * _root.scale, 142 * _root.scale, _root.scale, 1.0, 1.0, 1.0);
			}
			else
			{
				super.select(i);
			}
		}
		
		override protected function refresh() : void
		{
			if(_input)
			{
				var variables : URLVariables;
				variables = new URLVariables();
				variables.record = Base64.stringToBase64("{\"key\":\"" + _key + "\", \"score\":" + _score.toString() + ", \"time\":" + int(_time * 10).toString() + "}")
				
				var request : URLRequest;
				request = new URLRequest("http://176.31.106.6/pacman/add_record.php");
				request.method = URLRequestMethod.POST;
				request.data = variables;
				
				var loader : URLLoader;
				loader = new URLLoader();
				loader.addEventListener(IOErrorEvent.IO_ERROR, refreshErrorHandler);
				loader.addEventListener(Event.COMPLETE, refreshCompleteHandler);
				loader.dataFormat = URLLoaderDataFormat.VARIABLES;
				loader.load(request);
			}
			else
			{
				super.refresh();
			}
		}
		
		override protected function refreshCompleteHandler(event : Event) : void
		{
			if(_input)
			{
				var loader : URLLoader;
				loader = event.target as URLLoader;
				loader.removeEventListener(IOErrorEvent.IO_ERROR, refreshErrorHandler); 
				loader.removeEventListener(Event.COMPLETE, refreshCompleteHandler); 
				
				var variables : URLVariables;
				variables = loader.data;
				
				if(variables.retcode == 0)
				{
					for(i = 0 ; i < 10 ; i++)
					{
						if(variables["name_"+i] == _key)
							_offset = int(variables.rank) - i;
					}
					
					_orderby = variables.orderby;
					
					_records.clear();
					_records.print("rank", 10 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
					_records.print("name", 90 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
					_records.print("score", 160 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
					_records.print("time", 220 * _root.scale, 0, _root.scale, 0.64, 0.0, 0.0);
					
					for(var i : int = 0 ; i < 10 ; i++)
					{
						_records.print(int(_offset + i + 1).toString(), 20 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
						if(variables["name_"+i] == _key)
							_records.print(_name, 65 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
						else
							_records.print(variables["name_"+i], 65 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
						_records.print(variables["score_"+i], 170 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
						_records.print(Number(variables["time_"+i] / 10).toFixed(1), 230 * _root.scale, (11 * i + 16) * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
					}
					
					select(_menuSelection);
				}
			}
			else
			{
				super.refreshCompleteHandler(event);
			}
		}
		
		private function rename() : void
		{
			var variables : URLVariables;
			variables = new URLVariables();
			variables.record = Base64.stringToBase64("{\"key\":\"" + _key + "\", \"name\":\"" + _name + "\"}")
			
			var request : URLRequest;
			request = new URLRequest("http://176.31.106.6/pacman/update_record.php");
			request.method = URLRequestMethod.POST;
			request.data = variables;
			
			var loader : URLLoader;
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, renameErrorHandler);
			loader.addEventListener(Event.COMPLETE, renameCompleteHandler);
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.load(request);
			
			if(_root.bestRecord == null || _root.bestRecord.score < _score)
			{
				_root.bestRecord = new Record();
				_root.bestRecord.name = _name;
				_root.bestRecord.score = _score;
				_root.bestRecord.time = _time;
				_root.save();
			}
		}
		
		private function renameErrorHandler(event : IOErrorEvent) : void
		{
			var loader : URLLoader;
			loader = event.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, renameErrorHandler); 
			loader.removeEventListener(Event.COMPLETE, renameCompleteHandler); 
		}
		
		private function renameCompleteHandler(event : Event) : void
		{
			var loader : URLLoader;
			loader = event.target as URLLoader;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, renameErrorHandler); 
			loader.removeEventListener(Event.COMPLETE, renameCompleteHandler); 
			
			refresh();
			
			select(_menuSelection);
		}
		
		private function redrawName(i : int) : void
		{
			if(i >= Assets.CharList.length) i = 0;
			if(i < 0) i = Assets.CharList.length - 1;
			
			if(_index < _name.length - 1)
			{
				if(_index > 0)
					_name = _name.substr(0, _index) + Assets.CharList.charAt(i) + _name.substr(_index + 1);
				else
					_name = Assets.CharList.charAt(i) + _name.substr(_index + 1);
			}
			else
			{
				_name = _name.substr(0, _index) + Assets.CharList.charAt(i);
			}
		}
		
		override public function keyDownHandler(keyCode : int, charCode : int) : void
		{
			if(_input)
			{
				if(keyCode == Keyboard.LEFT)
				{
					_index--;
					if(_index < 0)
						_index = 0;
					
					select(_menuSelection);
				}
				else if(keyCode == Keyboard.RIGHT)
				{
					_index++;
					if(_index > _name.length)
						_index = _name.length;
					if(_index > 11)
						_index = 11;
					
					select(_menuSelection);
				}
				else if(keyCode == Keyboard.UP)
				{
					if(_index < _name.length)
					{
						redrawName(Assets.CharList.indexOf(_name.charAt(_index)) + 1);
					}
					else
					{
						_name += Assets.CharList.charAt(10);
					}
					
					select(_menuSelection);
				}
				else if(keyCode == Keyboard.DOWN)
				{
					if(_index < _name.length)
					{
						redrawName(Assets.CharList.indexOf(_name.charAt(_index)) - 1);
					}
					else
					{
						_name += Assets.CharList.charAt(36);
					}
					
					select(_menuSelection);
				}
				else if(keyCode == Keyboard.ENTER)
				{
					if(_input)
					{
						_input.dispose();
						_input = null;
					}
					
					if(_help)
					{
						_help.dispose();
						_help = null;
					}
					
					rename();
					
					_root.backKey.visible = true;
				}
			}
			else
			{
				super.keyDownHandler(keyCode, charCode);
			}
		}
	}
}