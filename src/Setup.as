package
{
	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Collision.b2AABB;
	import Box2DAS.Common.V2;
	import Box2DAS.Common.XF;
	import Box2DAS.Common.b2Transform;
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2BodyDef;
	import Box2DAS.Dynamics.b2DebugDraw;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;
	import Box2DAS.Dynamics.b2World;
	
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Linear;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class Setup implements State
	{
		private var _root : NotPacman;
		
		private var _view : Sprite;
		
		private var _setupSelection : int;
		
		private var _mouseCenter : Point;
		private var _mouseVector : Point;
		private var _mouseButtonDown : Boolean;
		
		private var _keyboardAngle : Number;
		private var _keyboardSpeed : Number;
		private var _keyLeftDown : Boolean;
		private var _keyRightDown : Boolean;
		
		private var _gyroscopeAngle : Number;
		private var _gyroscopeVector : Point;
		
		private var m_world : b2World;
		private var m_velocityIterations : int = 5;
		private var m_positionIterations : int = 5;
		private var m_timeStep : Number = 1.0 / NotPacman.FRAMERATE;
		private var m_gravity : V2;
		private var m_pacmanFixture : b2Fixture;
		
		private var _options : Sprite;
		private var _titles : Text;
		private var _schemes : Text;
		private var _description : Text;
		private var _field : Sprite;
		private var _pacman : Sprite;
		private var _render : Sprite;
		private var _anim : Sprite;
		private var _animPacman : Pacman;
		private var _animGhost1 : Ghost;
		private var _animGhost2 : Ghost;
		private var _animGhost3 : Ghost;
		private var _animTween : GTween;
		private var _animTimeoutId : uint;
		
		private var _controlMethod : String;
		
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
			_root.backKey.visible = true;
			_root.speedKey.visible = false;
			
			_controlMethod = _root.controlMethod;
			
			for(var k : int = 0 ; k < _root.controlMethods.length ; k++)
			{
				if(_controlMethod == _root.controlMethods[k])
					_setupSelection = k;
			}
			
			_keyboardAngle = Math.PI / 2;
			_keyboardSpeed = 2.0;
			
			_gyroscopeAngle = 0.0;
			_gyroscopeVector = new Point(0.0, 0.0);
			
			_options = Assets.spawnSprite(Assets.Options, true, false, 0, 0, _root.scale);
			_titles = new Text(Assets.Font, Assets.CharList, false);
			_schemes = new Text(Assets.Font, Assets.CharList, false);
			_description = new Text(Assets.Font, Assets.CharList, false);
			_field = Assets.spawnSprite(Assets.DemoField, true, false, 24, 24, 1.0 / 0.015);
			_pacman = Assets.spawnSprite(Assets.PacmanMan, true, false, 32, 32, 14.4);
			_render = new Sprite();
			_render.scaleX = 0.015 * _root.scale;
			_render.scaleY = 0.015 * _root.scale;
			_render.x = 220 * _root.scale;
			_render.y = 80 * _root.scale;
			_render.addChild(_field);
			_render.addChild(_pacman);
			_anim = new Sprite();
			_anim.x = 0.5 * _root.screenWidth;
			_anim.y = _root.screenHeight - 14 * _root.scale;
			_anim.graphics.lineStyle(1.0 * _root.scale, 0x1717FF);
			_anim.graphics.moveTo(-0.8 * _root.screenWidth, -10 * _root.scale);
			_anim.graphics.lineTo(+0.8 * _root.screenWidth, -10 * _root.scale);
			_anim.graphics.moveTo(-0.8 * _root.screenWidth, -8 * _root.scale);
			_anim.graphics.lineTo(+0.8 * _root.screenWidth, -8 * _root.scale);
			_anim.graphics.moveTo(-0.8 * _root.screenWidth, +8 * _root.scale);
			_anim.graphics.lineTo(+0.8 * _root.screenWidth, +8 * _root.scale);
			_anim.graphics.moveTo(-0.8 * _root.screenWidth, +10 * _root.scale);
			_anim.graphics.lineTo(+0.8 * _root.screenWidth, +10 * _root.scale);
			
			_mouseCenter = new Point(_render.x, _render.y);
			_mouseVector = new Point(0.0, 1.0);
			
			_titles.print("control scheme", 8 * _root.scale, 53 * _root.scale, _root.scale, 0.64, 0.0, 0.0);
			_titles.print("description", 153 * _root.scale, 135 * _root.scale, _root.scale, 0.64, 0.0, 0.0);
			
			_view = new Sprite();
			_view.addChild(_options);
			_view.addChild(_titles);
			_view.addChild(_schemes);
			_view.addChild(_description);
			_view.addChild(_render);
			_view.addChild(_anim);
			
			select(_setupSelection);
			
			createDemoWorld();
			
			_animTimeoutId = setTimeout(launchAnim, 500 + 1500 * Math.random(), +1.0);
		}
		
		private function launchAnim(s : Number) : void
		{
			_animPacman = new Pacman(1.4);
			_animPacman.scaleX = 0.015 * _root.scale;
			_animPacman.scaleY = 0.015 * _root.scale;
			_animPacman.x = -0.8 * s * _root.screenWidth;
			
			_animGhost1 = new Ghost(1);
			_animGhost1.scaleX = 0.2 * _root.scale;
			_animGhost1.scaleY = 0.2 * _root.scale;
			_animGhost1.x = _animPacman.x;
			
			_animGhost2 = new Ghost(2);
			_animGhost2.scaleX = 0.2 * _root.scale;
			_animGhost2.scaleY = 0.2 * _root.scale;
			_animGhost2.x = _animPacman.x;
			
			_animGhost3 = new Ghost(3);
			_animGhost3.scaleX = 0.2 * _root.scale;
			_animGhost3.scaleY = 0.2 * _root.scale;
			_animGhost3.x = _animPacman.x;
			
			_anim.addChild(_animPacman);
			_anim.addChild(_animGhost1);
			_anim.addChild(_animGhost2);
			_anim.addChild(_animGhost3);
			
			if(s > 0.0)
			{
				_animPacman.rotation = 180;
			}
			else
			{
				_animGhost1.setScared();
				_animGhost2.setScared();
				_animGhost3.setScared();
			}
			
			_animTimeoutId = 0;
			_animTween = new GTween(_animPacman, 3.0, {x: +0.8 * s * _root.screenWidth}, {ease: Linear.easeNone, onComplete: tweenCompleteHandler});
		}
		
		private function tweenCompleteHandler(t : GTween) : void
		{
			_animTween = null;
			
			if(_animPacman)
			{
				if(_animPacman.x < 0.0)
					_animTimeoutId = setTimeout(launchAnim, 9000 + 3000 * Math.random(), +1.0);
				else
					_animTimeoutId = setTimeout(launchAnim, 1000 + 2000 * Math.random(), -1.0);
				
				_animPacman.dispose();
				_animPacman = null;
			}
			
			if(_animGhost1)
			{
				_animGhost1.dispose();
				_animGhost1 = null;
			}
			
			if(_animGhost2)
			{
				_animGhost2.dispose();
				_animGhost2 = null;
			}
			
			if(_animGhost3)
			{
				_animGhost3.dispose();
				_animGhost3 = null;
			}
			
			if(_anim)
				_anim.removeChildren();
		}
		
		private function select(i : int) : void
		{
			_setupSelection = i;
			
			if(i >= 0 && i < _root.controlMethods.length)
				_controlMethod = _root.controlMethods[i];
			
			if(_controlMethod == "virtual pad")
			{
				_root.leftKey.visible = true;
				_root.rightKey.visible = true;
				_root.speedKey.visible = true;
			}
			else
			{
				_root.leftKey.visible = false;
				_root.rightKey.visible = false;
				_root.speedKey.visible = false;
			}
			
			var yOffset : int = 0;
			
			_schemes.clear();
			_description.clear();
			
			for(var k : int = 0 ; k < _root.controlMethods.length ; k++)
			{
				if(_root.controlMethod == _root.controlMethods[k])
					_schemes.print(">", 8 * _root.scale, (70 + yOffset) * _root.scale, _root.scale, 0.99, 0.45, 0.38);
				
				if(_setupSelection == k)
				{
					_schemes.print(_root.controlMethods[k], 18 * _root.scale, (70 + yOffset) * _root.scale, _root.scale, 1.0, 1.0, 1.0);
					
					_description.print(_root.controlDescriptions[_controlMethod], 153 * _root.scale, 150 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
				}
				else
				{
					_schemes.print(_root.controlMethods[k], 18 * _root.scale, (70 + yOffset) * _root.scale, _root.scale, 0.5, 0.5, 0.5);
				}
				
				yOffset += 20;
			}
			
			if(_root.reverseInput)
				_schemes.print(">", 8 * _root.scale, (70 + yOffset) * _root.scale, _root.scale, 0.99, 0.45, 0.38);
			
			if(_setupSelection == _root.controlMethods.length)
			{
				_schemes.print("reverse gravity", 18 * _root.scale, (70 + yOffset) * _root.scale, _root.scale, 1.0, 1.0, 1.0);
				
				_description.print("to fix bugs or\nadd more fun...", 153 * _root.scale, 150 * _root.scale, 0.75 * _root.scale, 1.0, 1.0, 1.0);
			}
			else
			{
				_schemes.print("reverse gravity", 18 * _root.scale, (70 + yOffset) * _root.scale, _root.scale, 0.5, 0.5, 0.5);
			}
			
			_schemes.graphics.clear();
			_description.graphics.clear();
				
			var b : Rectangle;
			b = _schemes.getBounds(_schemes);
			b.left -= 4 * _root.scale;
			b.top -= 4 * _root.scale;
			b.right += 4 * _root.scale;
			b.bottom += 4 * _root.scale;
			
			_schemes.graphics.lineStyle(2 * _root.scale, 0xFFFFFF, 1.0, true, "normal", "square");
			_schemes.graphics.moveTo(b.left + 1 * _root.scale, b.top);
			_schemes.graphics.lineTo(b.right - 1 * _root.scale, b.top);
			_schemes.graphics.moveTo(b.left, b.top + 1 * _root.scale);
			_schemes.graphics.lineTo(b.left, b.bottom - 1 * _root.scale);
			_schemes.graphics.moveTo(b.left + 1 * _root.scale, b.bottom);
			_schemes.graphics.lineTo(b.right - 1 * _root.scale, b.bottom);
			_schemes.graphics.moveTo(b.right, b.top + 1 * _root.scale);
			_schemes.graphics.lineTo(b.right, b.bottom - 1 * _root.scale);
			
			b = _description.getBounds(_description);
			b.left -= 4 * _root.scale;
			b.top -= 4 * _root.scale;
			b.right += 4 * _root.scale;
			b.bottom += 4 * _root.scale;
			
			_description.graphics.lineStyle(2 * _root.scale, 0xFFFFFF, 1.0, true, "normal", "square");
			_description.graphics.moveTo(b.left + 1 * _root.scale, b.top);
			_description.graphics.lineTo(b.right - 1 * _root.scale, b.top);
			_description.graphics.moveTo(b.left, b.top + 1 * _root.scale);
			_description.graphics.lineTo(b.left, b.bottom - 1 * _root.scale);
			_description.graphics.moveTo(b.left + 1 * _root.scale, b.bottom);
			_description.graphics.lineTo(b.right - 1 * _root.scale, b.bottom);
			_description.graphics.moveTo(b.right, b.top + 1 * _root.scale);
			_description.graphics.lineTo(b.right, b.bottom - 1 * _root.scale);
		}
		
		public function unload() : void
		{
			_render = null;
			
			if(_animTimeoutId)
				clearTimeout(_animTimeoutId);
			
			if(_animTween)
			{
				_animTween.paused = true;
				_animTween = null;
			}
			
			if(_animPacman)
			{
				_animPacman.dispose();
				_animPacman = null;
			}
			
			if(_animGhost1)
			{
				_animGhost1.dispose();
				_animGhost1 = null;
			}
			
			if(_animGhost2)
			{
				_animGhost2.dispose();
				_animGhost2 = null;
			}
			
			if(_animGhost3)
			{
				_animGhost3.dispose();
				_animGhost3 = null;
			}
			
			if(_anim)
			{
				_anim.removeChildren();
				_anim = null;
			}
			
			if(_pacman)
			{
				Assets.releaseSprite(_pacman);
				_pacman = null;
			}
			
			if(_field)
			{
				Assets.releaseSprite(_field);
				_field = null;
			}
			
			if(_description)
			{
				_description.dispose();
				_description = null;
			}
			
			if(_schemes)
			{
				_schemes.dispose();
				_schemes = null;
			}
			
			if(_titles)
			{
				_titles.dispose();
				_titles = null;
			}
			
			if(_options)
			{
				Assets.releaseSprite(_options);
				_options = null;
			}
			
			if(_view)
			{
				_view.removeChildren();
				_view = null;
			}
			
			_root = null;
		}
		
		private function createDemoWorld() : void
		{
			// Define the gravity vector
			updateGravity();
			
			// Construct a world object
			m_world = new b2World(m_gravity, false);
			m_world.SetWarmStarting(true);
			
			// Create border of boxes
			var wall : b2PolygonShape = new b2PolygonShape();
			var wallBd : b2BodyDef = new b2BodyDef();
			var wallB : b2Body;
			var fixture : b2Fixture;
			
			// Left
			wall.SetAsBox(1 * _root.scale, 16 * _root.scale);
			wallBd.position.x = -16 * _root.scale;
			wallBd.position.y = 0;
			wallB = m_world.CreateBody(wallBd);
			fixture = wallB.CreateFixtureShape(wall, 1.0);
			// Right
			wallBd.position.x = +16 * _root.scale;
			wallBd.position.y = 0;
			wallB = m_world.CreateBody(wallBd);
			fixture = wallB.CreateFixtureShape(wall, 1.0);
			// Top
			wall.SetAsBox(16 * _root.scale, 1 * _root.scale);
			wallBd.position.x = 0;
			wallBd.position.y = +16 * _root.scale;
			wallB = m_world.CreateBody(wallBd);
			fixture = wallB.CreateFixtureShape(wall, 1.0);
			// Bottom
			wallBd.position.x = 0;
			wallBd.position.y = -16 * _root.scale;
			wallB = m_world.CreateBody(wallBd);
			fixture = wallB.CreateFixtureShape(wall, 1.0);
			// Center
			wallBd.position.x = 0;
			wallBd.position.y = 0;
			wall.SetAsBox(2 * _root.scale, 2 * _root.scale);
			wallB = m_world.CreateBody(wallBd);
			fixture = wallB.CreateFixtureShape(wall, 1.0);
			
			// Add bodies
			var bd : b2BodyDef = new b2BodyDef();
			bd.position.x = -5.5 * _root.scale;
			bd.position.y = -6.5 * _root.scale;
			bd.type = b2Body.b2_dynamicBody;
			bd.bullet = true;
			var fd : b2FixtureDef = new b2FixtureDef();
			fd.density = 1.0;
			fd.friction = 1000;
			fd.restitution = 0.1;
			fd.shape = new b2CircleShape();
			fd.shape.m_radius = 4.5 * _root.scale;
			var b : b2Body;
			b = m_world.CreateBody(bd);
			m_pacmanFixture = b.CreateFixture(fd);
		}
		
		public function update(dt : Number) : void
		{
			if(_root.controlMethod == "keyboard" || _root.controlMethod == "virtual pad")
			{
				if(_keyLeftDown)
					_keyboardAngle += _keyboardSpeed * dt;
				
				if(_keyRightDown)
					_keyboardAngle -= _keyboardSpeed * dt;
			}
			
			// Clear for rendering
			_render.graphics.clear();
			
			// Update the gravity vector
			updateGravity();
			
			// Update physics
			m_world.SetGravity(m_gravity);
			m_world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			m_world.ClearForces();
			
			// Render
			
			var visualAngle : Number;
			visualAngle = -Math.atan2(m_gravity.y, m_gravity.x);
			visualAngle += Math.PI / 2;
			
			if(_root.controlMethod.indexOf("gyroscope") > -1)
				_render.rotation = 0.0;
			else
				_render.rotation = visualAngle * 180.0 / Math.PI;
			
			var transform : XF = m_pacmanFixture.GetBody().GetTransform();
			
			_pacman.x = transform.p.x / 0.034;
			_pacman.y = transform.p.y / 0.034;
			_pacman.rotation = transform.angle * 180 / Math.PI;
			
			if(_animPacman)
			{
				_animGhost1.x = _animPacman.x - 50 * _root.scale;
				_animGhost2.x = _animPacman.x - 70 * _root.scale;
				_animGhost3.x = _animPacman.x - 90 * _root.scale;
				
				_animPacman.animate();
			}
		}
		
		private function updateGravity() : void
		{
			const GRAVITY : Number = 800.0;
			
			if(_root.controlMethod == "keyboard")
				m_gravity = new V2(GRAVITY * Math.cos(_keyboardAngle), GRAVITY * Math.sin(_keyboardAngle));
			else if(_root.controlMethod == "mouse")
				m_gravity = new V2(GRAVITY * _mouseVector.x, GRAVITY * -_mouseVector.y);
			else if(_root.controlMethod == "planar gyroscope")
				m_gravity = new V2(GRAVITY * _gyroscopeVector.x, GRAVITY * -_gyroscopeVector.y);
			else if(_root.controlMethod == "wheel gyroscope")
				m_gravity = new V2(GRAVITY * Math.cos(_gyroscopeAngle), GRAVITY * Math.sin(_gyroscopeAngle));
			else if(_root.controlMethod == "virtual pad")
				m_gravity = new V2(GRAVITY * Math.cos(_keyboardAngle), GRAVITY * Math.sin(_keyboardAngle));
			else if(_root.controlMethod == "touch screen")
				m_gravity = new V2(GRAVITY * _mouseVector.x, GRAVITY * -_mouseVector.y);
		}
		
		public function draw() : void
		{
			_options.x = _root.screenWidth / 2 - 32 * _root.scale;
			_options.y = 14 * _root.scale;
		}
		
		public function keyDownHandler(keyCode : int, charCode : int) : void
		{
			if(keyCode == Keyboard.ESCAPE)
			{
				_root.save();
				_root.setState("menu");
				
				return;
			}
			
			if(keyCode == Keyboard.SHIFT)
				_keyboardSpeed = 4.0;
			else if(keyCode == Keyboard.LEFT)
				_keyLeftDown = true;
			else if(keyCode == Keyboard.RIGHT)
				_keyRightDown = true;
			else if(keyCode == Keyboard.UP)
				_setupSelection--;
			else if(keyCode == Keyboard.DOWN)
				_setupSelection++;
			else if(keyCode == Keyboard.ENTER)
			{
				if(_setupSelection == _root.controlMethods.length)
					_root.reverseInput = !_root.reverseInput;
				else
					_root.controlMethod = _controlMethod;
			}
			
			if(_setupSelection < 0)
				_setupSelection = _root.controlMethods.length;
			else if(_setupSelection > _root.controlMethods.length)
				_setupSelection = 0;
			
			select(_setupSelection);
		}
		
		public function keyUpHandler(keyCode : int, charCode : int) : void
		{
			if(keyCode == Keyboard.SHIFT)
				_keyboardSpeed = 2.0;
			else if(keyCode == Keyboard.LEFT)
				_keyLeftDown = false;
			else if(keyCode == Keyboard.RIGHT)
				_keyRightDown = false;
		}
		
		public function mouseClickHandler(x : Number, y : Number) : void
		{
		}
		
		public function mouseMoveHandler(x : Number, y : Number) : void
		{
			if(_mouseButtonDown)
			{
				_mouseVector.x = x - _mouseCenter.x;
				_mouseVector.y = y - _mouseCenter.y;
				_mouseVector.normalize(1.0);
			}
		}
		
		public function mouseDownHandler(x : Number, y : Number) : void
		{
			_mouseButtonDown = true;
		}
		
		public function mouseUpHandler(x : Number, y : Number) : void
		{
			_mouseButtonDown = false;
		}
		
		public function gyroscopeUpdateHandler(x : Number, y : Number, z : Number) : void
		{
			_gyroscopeAngle = (z / 90 * Math.PI) + Math.PI / 2;
			
			_gyroscopeVector.x = x / 20;
			_gyroscopeVector.y = y / 20;
		}
	}
}