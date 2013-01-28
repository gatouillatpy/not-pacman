package
{
	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.V2;
	import Box2DAS.Common.XF;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2BodyDef;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;
	import Box2DAS.Dynamics.b2World;
	
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class Game implements State
	{
		private var _root : NotPacman;
		
		private var _view : Sprite;
		
		private var _mouseCenter : Point;
		private var _mouseVector : Point;
		private var _mouseButtonDown : Boolean;
		
		private var _keyboardAngle : Number;
		private var _keyboardSpeed : Number;
		private var _keyLeftDown : Boolean;
		private var _keyRightDown : Boolean;
		
		private var _gyroscopeAngle : Number;
		private var _gyroscopeVector : Point;
		
		private var m_velocityIterations : int = 5;
		private var m_positionIterations : int = 5;
		private var m_timeStep : Number = 1.0 / NotPacman.FRAMERATE;
		private var m_world : b2World;
		private var m_gravity : V2;
		private var m_pacmanFixture : b2Fixture;
		private var m_ghost1Fixture : b2Fixture;
		private var m_ghost2Fixture : b2Fixture;
		private var m_ghost3Fixture : b2Fixture;
		
		private var _field : Sprite;
		private var _simplePellets : Vector.<Shape>;
		private var _superPellets : Shape;
		private var _pacman : Pacman;
		private var _ghost1 : Ghost;
		private var _ghost2 : Ghost;
		private var _ghost3 : Ghost;
		private var _render : Sprite;
		private var _timeLabel : Sprite;
		private var _timeText : Text;
		private var _scoreLabel : Sprite;
		private var _scoreText : Text;
		
		private var _dying : Boolean;
		private var _hunting : Boolean;
		private var _winning : Boolean;
		
		private var _lives : int;
		private var _score : int;
		private var _time : Number;
		
		private var _timeStart : Number;
		
		private var _restoreTimeoutId : uint;
		private var _respawnTimeoutId : uint;
		
		private var _huntCombo : int;
		
		private var _pelletMap : Array;
		private var _pelletCount : int;
		
		private var _simplePelletsUpdate : Array;
		private var _superPelletsUpdate : Boolean;
		
		private var _posGhost1 : Point;
		private var _posGhost2 : Point;
		private var _posGhost3 : Point;
		
		private var _livesSprite : Sprite;
		private var _livesText : Text;
		
		private var _wakaWaTime : int;
		private var _wakaKaTime : int;
		private var _eatGhostTime : int;
		
		private var _runawaySound : SoundChannel;
		private var _sirenSound : SoundChannel;
		
		public function get view() : Sprite
		{
			return _view;
		}
		
		public function load(root : NotPacman) : void
		{
			_root = root;
			_root.upKey.visible = false;
			_root.downKey.visible = false;
			_root.okKey.visible = false;
			_root.leftKey.visible = false;
			_root.rightKey.visible = false;
			_root.backKey.visible = true;
			_root.speedKey.visible = false;
			
			if(_root.controlMethod == "virtual pad")
			{
				_root.leftKey.visible = true;
				_root.rightKey.visible = true;
				_root.speedKey.visible = true;
			}
			
			_dying = false;
			_hunting = false;
			_winning = false;
			
			_lives = 3;
			_score = 0;
			_time = 0.0;
			
			_timeStart = NaN;
			
			_huntCombo = 1;
			
			_keyboardAngle = Math.PI / 2;
			_keyboardSpeed = 2.0;
			
			_gyroscopeAngle = Math.PI / 2;
			_gyroscopeVector = new Point(0.0, 0.0);
			
			_pelletMap =
			[
				[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], //--shit man
				[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], //--26x29
				[2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2], //--1 = pellet
				[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], //--2 = super pellet
				[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], //--244 total (240 normal + 4 super)
				[1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1], //--It's [y][x]!
				[1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1],
				[1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
				[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
				[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
				[2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2],
				[1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1],
				[0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
				[0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
				[1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1],
				[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
				[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
			];
			_pelletCount = 244;
			
			_simplePelletsUpdate = [];
			for(var k : int = 0 ; k < _pelletMap.length ; k++)
				_simplePelletsUpdate[k] = true;
			_superPelletsUpdate = true;
			
			_field = Assets.spawnSprite(Assets.Field, true, false, 110, 108, 1.0 / 0.015);
			_field.blendMode = BlendMode.ADD;
			_simplePellets = new Vector.<Shape>(_pelletMap.length, true);
			for(k = 0 ; k < _simplePellets.length ; k++)
				_simplePellets[k] = new Shape();
			_superPellets = new Shape();
			_pacman = new Pacman(1.4);
			_ghost1 = new Ghost(1);
			_ghost2 = new Ghost(2);
			_ghost3 = new Ghost(3);
			_render = new Sprite();
			_render.scaleX = 0.015 * _root.scale;
			_render.scaleY = 0.015 * _root.scale;
			_render.x = 0.5 * _root.screenWidth;
			_render.y = 0.5 * _root.screenHeight;
			_render.addChild(_field);
			for(k = 0 ; k < _simplePellets.length ; k++)
				_render.addChild(_simplePellets[k]);
			_render.addChild(_superPellets);
			_render.addChild(_pacman);
			_render.addChild(_ghost1);
			_render.addChild(_ghost2);
			_render.addChild(_ghost3);
			_timeLabel = Assets.spawnSprite(Assets.GameTime, true, false, 15, 8, _root.scale);
			_timeLabel.x = 20 * _root.scale;
			_timeLabel.y = 20 * _root.scale;
			_timeText = new Text(Assets.Font, Assets.CharList, false);
			_timeText.x = 6 * _root.scale;
			_timeText.y = 36 * _root.scale;
			_timeText.print("000.00", 0.0, 0.0, 3.0, 0.5, 0.5, 0.5);
			_scoreLabel = Assets.spawnSprite(Assets.GameScore, true, false, 15, 8, _root.scale);
			_scoreLabel.x = 20 * _root.scale;
			_scoreLabel.y = 70 * _root.scale;
			_scoreText = new Text(Assets.Font, Assets.CharList, false);
			_scoreText.x = 6 * _root.scale;
			_scoreText.y = 86 * _root.scale;
			_scoreText.print("000000", 0.0, 0.0, 3.0, 0.5, 0.5, 0.5);
			_livesSprite = Assets.spawnSprite(Assets.PacmanMan, true, false, 15, 8, 0.25 * _root.scale);
			_livesSprite.rotation = 180;
			_livesSprite.x = 20 * _root.scale;
			_livesSprite.y = 130 * _root.scale;
			_livesText = new Text(Assets.Font, Assets.CharList, false);
			_livesText.x = 28 * _root.scale;
			_livesText.y = 120 * _root.scale;
			_livesText.print("x3", 0.0, 0.0, 3.0, 0.5, 0.5, 0.5);
			
			_mouseCenter = new Point(_render.x, _render.y);
			_mouseVector = new Point(0.0, 1.0);
			
			_view = new Sprite();
			_view.addChild(_render);
			_view.addChild(_timeLabel);
			_view.addChild(_timeText);
			_view.addChild(_scoreLabel);
			_view.addChild(_scoreText);
			_view.addChild(_livesSprite);
			_view.addChild(_livesText);
			
			createWorld();
			
			_wakaWaTime = 0;
			_wakaKaTime = 0;
			_eatGhostTime = 0;
			
			Assets.playSound(Assets.PacmanBeginning);
			
			_sirenSound = Assets.playSound(GhostsSiren, true, 0.0);
		}
		
		public function unload() : void
		{
			_render = null;
			
			if(_ghost3)
			{
				_ghost3.dispose();
				_ghost3 = null;
			}
			
			if(_ghost2)
			{
				_ghost2.dispose();
				_ghost2 = null;
			}
			
			if(_ghost1)
			{
				_ghost1.dispose();
				_ghost1 = null;
			}
			
			if(_pacman)
			{
				_pacman.dispose();
				_pacman = null;
			}
			
			if(_field)
			{
				Assets.releaseSprite(_field);
				_field = null;
			}
			
			if(_view)
			{
				_view.removeChildren();
				_view = null;
			}
			
			m_world = null;
			m_gravity = null;
			m_pacmanFixture = null;
			m_ghost1Fixture = null;
			m_ghost2Fixture = null;
			m_ghost3Fixture = null;
			
			if(_respawnTimeoutId)
				clearTimeout(_respawnTimeoutId);
			
			if(_restoreTimeoutId)
				clearTimeout(_restoreTimeoutId);
			
			_root = null;
		}
		
		private function createBox(x : Number, y : Number, w : Number, h : Number) : void
		{
			var wall : b2PolygonShape = new b2PolygonShape();
			wall.SetAsBox(0.4 * w * _root.scale, 0.4 * h * _root.scale);
			
			var wallBd : b2BodyDef = new b2BodyDef();
			wallBd.position.x = 0.4 * x * _root.scale;
			wallBd.position.y = 0.4 * y * _root.scale;
			
			var wallB : b2Body;
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixtureShape(wall, 1.0);
		}
		
		private function createActor(x : Number, y : Number, r : Number) : b2Fixture
		{
			var bd : b2BodyDef = new b2BodyDef();
			bd.position.x = x * _root.scale;
			bd.position.y = y * _root.scale;
			bd.type = b2Body.b2_dynamicBody;
			bd.bullet = true;
			
			var fd : b2FixtureDef = new b2FixtureDef();
			fd.density = 1.0;
			fd.friction = 100;
			fd.restitution = 0.1;
			fd.shape = new b2CircleShape();
			fd.shape.m_radius = r * _root.scale;
			
			var b : b2Body;
			b = m_world.CreateBody(bd);
			return b.CreateFixture(fd);
		}
		
		private function createWorld() : void
		{
			// Define the gravity vector
			updateGravity();
			
			// Construct a world object
			m_world = new b2World(m_gravity, false);
			m_world.SetWarmStarting(true);
			
			//_debug = new b2DebugDraw(m_world);
			//_debug.scaleX = 1.125 / 0.015;
			//_debug.scaleY = 1.125 / 0.015;
			//_debug.alpha = 0.5;
			//_render.addChild(_debug);
			
			createBox(0, -77.5, 80, 1.5);
			createBox(0, -66, 4, 10.5);
			
			createBox(-58, -43, 9.5, 3);
			createBox(+58, -43, 9.5, 3);
			
			createBox(0, -43, 21, 3);
			createBox(0, -33, 4, 8);
			
			createBox(0, -5, 21, 10.5);
			
			createBox(0, +17.5, 21, 3);
			createBox(0, +27.5, 4, 8);
			
			createBox(0, +48, 21, 3);
			createBox(0, +58, 4, 8);
			
			createBox(-34.5, +10, 4, 10.5);
			createBox(+34.5, +10, 4, 10.5);
			
			createBox(-34.5, -28, 4, 18);
			createBox(-22.5, -28, 9, 3);
			
			createBox(+34.5, -28, 4, 18);
			createBox(+22.5, -28, 9, 3);
			
			createBox(-26, +32.75, 12.5, 3);
			createBox(+26, +32.75, 12.5, 3);
			
			createBox(-58, +32.75, 9.5, 3);
			createBox(-52.25, +43, 3.75, 7.5);
			
			createBox(+58, +32.75, 9.5, 3);
			createBox(+52.25, +43, 3.75, 7.5);
			
			createBox(-26, -61, 12.5, 5);
			createBox(+26, -61, 12.5, 5);
			
			createBox(-58, -61, 9.5, 5);
			createBox(+58, -61, 9.5, 5);
			
			createBox(-64, -29, 16, 1.5);
			createBox(+64, -29, 16, 1.5);
			
			createBox(-64, -11.5, 16, 1.5);
			createBox(+64, -11.5, 16, 1.5);
			
			createBox(-64, +1.5, 16, 1.5);
			createBox(+64, +1.5, 16, 1.5);
			
			createBox(-64, +19, 16, 1.5);
			createBox(+64, +19, 16, 1.5);
			
			createBox(0, +77.5, 80, 1.5);
			
			createBox(-79, -53.25, 1.5, 25);
			createBox(+79, -53.25, 1.5, 25);
			
			createBox(-50, -20.25, 1.5, 10);
			createBox(+50, -20.25, 1.5, 10);
			
			createBox(-50, +10.25, 1.5, 10);
			createBox(+50, +10.25, 1.5, 10);
			
			createBox(-79, +48.25, 1.5, 28);
			createBox(-72, +48, 6.5, 3);
			
			createBox(+79, +48.25, 1.5, 28);
			createBox(+72, +48, 6.5, 3);
			
			createBox(-34.5, +53, 4, 8);
			createBox(+34.5, +53, 4, 8);
			
			createBox(-40.5, +63, 27, 2.75);
			createBox(+40.5, +63, 27, 2.75);
			
			m_pacmanFixture = createActor(0.0, 15.5, 1.6);
			m_ghost1Fixture = createActor(-5.0, -9.5, 1.6);
			m_ghost2Fixture = createActor(0.0, -9.5, 1.6);
			m_ghost3Fixture = createActor(+5.0, -9.5, 1.6);
		}
		
		public function update(dt : Number) : void
		{
			if(_winning) return;
			
			if(_root.controlMethod == "keyboard" || _root.controlMethod == "virtual pad")
			{
				if(_keyLeftDown)
					_keyboardAngle += _keyboardSpeed * dt;
				
				if(_keyRightDown)
					_keyboardAngle -= _keyboardSpeed * dt;
			}
			
			// Update the gravity vector
			updateGravity();
			
			// -- Field
			
			var visualAngle : Number;
			visualAngle = -Math.atan2(m_gravity.y, m_gravity.x);
			visualAngle += Math.PI / 2;
			
			if(_root.controlMethod.indexOf("gyroscope") > -1)
				_render.rotation = 0.0;
			else
				_render.rotation = visualAngle * 180.0 / Math.PI;
			
			if(_dying) return;
			
			// Update physics
			m_world.SetGravity(m_gravity);
			m_world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			m_world.ClearForces();
			
			// -- Ghost #1
			
			body = m_ghost1Fixture.GetBody();
			transform = body.GetTransform();
			
			if(transform.p.x < -100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x < 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			if(transform.p.x > +100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x > 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			var dx1 : Number = _ghost1.x;
			var dy1 : Number = _ghost1.y;
			
			if(_ghost1.alive)
			{
				_ghost1.x = transform.p.x / 0.0133;
				_ghost1.y = transform.p.y / 0.0133;
				_ghost1.rotation = transform.angle * 180 / Math.PI;
			}
			else
			{
				m_ghost1Fixture.GetBody().SetTransform(new V2(-5.0, -9.5), 0.0);
			}
			
			dx1 -= _ghost1.x;
			dy1 -= _ghost1.y;
			
			if(_posGhost1 == null)
				_posGhost1 = new Point(_ghost1.x, _ghost1.y);
			
			// -- Ghost #2
			
			body = m_ghost2Fixture.GetBody();
			transform = body.GetTransform();
			
			if(transform.p.x < -100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x < 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			if(transform.p.x > +100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x > 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			var dx2 : Number = _ghost2.x;
			var dy2 : Number = _ghost2.y;
			
			if(_ghost2.alive)
			{
				_ghost2.x = transform.p.x / 0.0133;
				_ghost2.y = transform.p.y / 0.0133;
				_ghost2.rotation = transform.angle * 180 / Math.PI;
			}
			else
			{
				m_ghost2Fixture.GetBody().SetTransform(new V2(0.0, -9.5), 0.0);
			}
			
			dx2 -= _ghost2.x;
			dy2 -= _ghost2.y;
			
			if(_posGhost2 == null)
				_posGhost2 = new Point(_ghost2.x, _ghost2.y);
			
			// -- Ghost #3
			
			body = m_ghost3Fixture.GetBody();
			transform = body.GetTransform();
			
			if(transform.p.x < -100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x < 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			if(transform.p.x > +100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x > 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			var dx3 : Number = _ghost3.x;
			var dy3 : Number = _ghost3.y;
			
			if(_ghost3.alive)
			{
				_ghost3.x = transform.p.x / 0.0133;
				_ghost3.y = transform.p.y / 0.0133;
				_ghost3.rotation = transform.angle * 180 / Math.PI;
			}
			else
			{
				m_ghost3Fixture.GetBody().SetTransform(new V2(+5.0, -9.5), 0.0);
			}
			
			dx3 -= _ghost3.x;
			dy3 -= _ghost3.y;
			
			if(_posGhost3 == null)
				_posGhost3 = new Point(_ghost3.x, _ghost3.y);
			
			var ds : Number = Math.sqrt(dx1 * dx1 + dy1 * dy1)
				+ Math.sqrt(dx2 * dx2 + dy2 * dy2)
				+ Math.sqrt(dx3 * dx3 + dy3 * dy3);
			if(ds < 5.0) ds = 5.0;
			if(ds > 400.0) ds = 400.0;
			if(_runawaySound) ds = 0.0;
			
			_sirenSound.soundTransform = new SoundTransform(ds / 400.0);
			
			// -- Pacman
			
			var body : b2Body = m_pacmanFixture.GetBody();
			var transform : XF = body.GetTransform();
			
			if(transform.p.x < -100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x < 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			if(transform.p.x > +100 && transform.p.y < 0 && transform.p.y > -10 && body.m_linearVelocity.x > 0)
				body.SetTransform(new V2(-transform.p.x, transform.p.y), transform.angle);
			
			_pacman.x = transform.p.x / 0.0133;
			_pacman.y = transform.p.y / 0.0133;
			_pacman.rotation = transform.angle * 180 / Math.PI;
			
			var dx : Number;
			var dy : Number;
			var hit : Boolean;
			
			dx = _pacman.x - _ghost1.x;
			dy = _pacman.y - _ghost1.y;
			hit = Math.sqrt(dx * dx + dy * dy) < 800;
			
			if(hit && _ghost1.alive)
			{
				if(_hunting)
				{
					_ghost1.die(_posGhost1);
					
					Assets.playSound(Assets.PacmanEatGhost);
					
					_score += 200 * _huntCombo;
					_huntCombo *= 2;
				}
				else
				{
					_dying = true;
				}
			}
			
			dx = _pacman.x - _ghost2.x;
			dy = _pacman.y - _ghost2.y;
			hit = Math.sqrt(dx * dx + dy * dy) < 800;
			
			if(hit && _ghost2.alive)
			{
				if(_hunting)
				{
					_ghost2.die(_posGhost2);
					
					Assets.playSound(Assets.PacmanEatGhost);
					
					_score += 200 * _huntCombo;
					_huntCombo *= 2;
				}
				else
				{
					_dying = true;
				}
			}
			
			dx = _pacman.x - _ghost3.x;
			dy = _pacman.y - _ghost3.y;
			hit = Math.sqrt(dx * dx + dy * dy) < 800;
			
			if(hit && _ghost3.alive)
			{
				if(_hunting)
				{
					_ghost3.die(_posGhost3);
					
					Assets.playSound(Assets.PacmanEatGhost);
					
					_score += 200 * _huntCombo;
					_huntCombo *= 2;
				}
				else
				{
					_dying = true;
				}
			}
			
			if(_dying)
			{
				_pacman.die();
				
				_respawnTimeoutId = setTimeout(respawn, 3000);
				
				_time += _root.getTime() - _timeStart;
				_timeStart = NaN;
				
				Assets.playSound(Assets.PacmanDeath);
				
				return;
			}
			
			var scale : Number = 1.0 / 0.015;
			
			var h : int = _pelletMap.length
			var w : int = _pelletMap[0].length
			
			var fx : Number = 8.0 * scale;
			var fy : Number = 7.0 * scale;
			var ox : Number = -0.5 * fx * w + 4.0 * scale;
			var oy : Number = -0.5 * fy * h + 3.5 * scale;
			var x : int = Math.round((_pacman.x - ox) / fx);
			var y : int = Math.round((_pacman.y - oy) / fy);
			
			var _pelletLine : Array = _pelletMap[y];
			
			if(_pelletLine[x] == 1)
			{
				_pelletLine[x] = 0;
				_pelletCount--;
				
				var time : int = getTimer();
				
				if(_wakaKaTime < _wakaWaTime)
				{
					if(_wakaKaTime < time)
					{
						Assets.playSound(Assets.PacmanWakaKa);
						
						_wakaKaTime = time + 200;
						_wakaWaTime = time + 100;
					}
				}
				else
				{
					if(_wakaWaTime < time)
					{
						Assets.playSound(Assets.PacmanWakaWa);
						
						_wakaWaTime = time + 200;
						_wakaKaTime = time + 100;
					}
				}
				
				_simplePelletsUpdate[y] = true;
				
				_score += 10;
				
				_pacman.animate();
			}
			else if(_pelletLine[x] == 2)
			{
				_pelletLine[x] = 0;
				_pelletCount--;
				
				_superPelletsUpdate = true;
				
				if(_runawaySound == null)
					_runawaySound = Assets.playSound(GhostsRunaway, true);
				
				_score += 50;
				
				_ghost1.setScared();
				_ghost2.setScared();
				_ghost3.setScared();
				
				_hunting = true;
				
				if(_restoreTimeoutId)
					clearTimeout(_restoreTimeoutId);
				
				_restoreTimeoutId = setTimeout(restore, 7000);
				
				_pacman.animate();
			}
			
			if(_score > 0)
			{
				if(isNaN(_timeStart))
					_timeStart = _root.getTime();
				
				var timeString : String;
				timeString = Number(_time + _root.getTime() - _timeStart).toFixed(2);
				
				while(timeString.length < 6)
					timeString = "0" + timeString;
				
				if(timeString.length > 6)
					timeString = "999.99";
				
				_timeText.clear();
				_timeText.print(timeString, 0.0, 0.0, 3.0, 0.5, 0.5, 0.5);
				
				var scoreString : String;
				scoreString = int(_score).toString();
				
				while(scoreString.length < 6)
					scoreString = "0" + scoreString;
				
				if(scoreString.length > 6)
					scoreString = "999999";
				
				_scoreText.clear();
				_scoreText.print(scoreString, 0.0, 0.0, 3.0, 0.5, 0.5, 0.5);
			}
			
			if(_pelletCount == 0)
			{
				_winning = true;
				
				Assets.playSound(Assets.PacmanWin);
				
				setTimeout(finalize, 3000);
			}
		}
		
		private function respawn() : void
		{
			_lives -= 1;
			_livesText.clear();
			_livesText.print("x" + _lives.toString(), 0.0, 0.0, 3.0, 0.5, 0.5, 0.5);
			
			if(_lives > 0)
			{
				_pacman.angle = 1.4;
				
				m_pacmanFixture.GetBody().SetTransform(new V2(0.0, 15.5), 0.0);
				m_ghost1Fixture.GetBody().SetTransform(new V2(-5.0, -9.5), 0.0);
				m_ghost2Fixture.GetBody().SetTransform(new V2(0.0, -9.5), 0.0);
				m_ghost3Fixture.GetBody().SetTransform(new V2(+5.0, -9.5), 0.0);
				
				_dying = false;
			}
			else
			{
				setTimeout(finalize, 2000);
			}
		}
		
		private function restore() : void
		{
			_ghost1.setNormal();
			_ghost2.setNormal();
			_ghost3.setNormal();
			
			_hunting = false;
			
			if(_runawaySound)
			{
				_runawaySound.stop();
				_runawaySound = null;
			}
			
			_huntCombo = 1;
		}
		
		private function finalize() : void
		{
			_root.tempRecord = new Record();
			_root.tempRecord.name = "";
			_root.tempRecord.score = _score;
			if(isNaN(_timeStart))
				_root.tempRecord.time = _time;
			else
				_root.tempRecord.time = _time + _root.getTime() - _timeStart;
			
			_root.setState("result");
		}
		
		private function updateGravity() : void
		{
			const GRAVITY : Number = 1200.0;
			
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
			//_debug.Draw();
			
			var _simplePelletsGfx : Graphics;
			var _superPelletsGfx : Graphics;
			
			var scale : Number = 1.0 / 0.015;
			
			var h : int = _pelletMap.length;
			var w : int = _pelletMap[0].length;
			
			var t1 : Number = 1.0 * scale;
			var t2 : Number = 2.0 * scale;
			var t3 : Number = 3.0 * scale;
			var t4 : Number = 4.0 * scale;
			var t6 : Number = 6.0 * scale;
			var fx : Number = 8.0 * scale;
			var fy : Number = 7.0 * scale;
			var ox : Number = -0.5 * fx * w + 4.0 * scale;
			var oy : Number = -0.5 * fy * h + 3.5 * scale;
			
			var dsp : Boolean = ((2 * _root.getTime()) % 2) < 1;
			
			if(dsp || _dying)
				_superPellets.visible = true;
			else
				_superPellets.visible = false;
			
			for(var y : int = 0 ; y < h ; y++)
			{
				if(_simplePelletsUpdate[y])
				{
					var _pelletLine : Array = _pelletMap[y];
					
					_simplePelletsGfx = _simplePellets[y].graphics;
					_simplePelletsGfx.clear();
					
					for(var x : int = 0 ; x < w ; x++)
					{
						var pellet : int = _pelletLine[x];
						
						var tx : Number = ox + x * fx;
						var ty : Number = oy + y * fy;
						
						if(pellet == 1)
						{
							_simplePelletsGfx.beginFill(0xFFFF00);
							_simplePelletsGfx.drawRect(tx - t1, ty - t1, t2, t2);
							_simplePelletsGfx.endFill();
						}
					}
					
					_simplePelletsUpdate[y] = false;
				}
			}
			
			if(_superPelletsUpdate)
			{
				_superPelletsGfx = _superPellets.graphics;
				_superPelletsGfx.clear();
				
				for(y = 0 ; y < h ; y++)
				{
					_pelletLine = _pelletMap[y];
					
					for(x = 0 ; x < w ; x++)
					{
						pellet = _pelletLine[x];
						
						tx = ox + x * fx;
						ty = oy + y * fy;
						
						if(pellet == 2)
						{
							if(_superPelletsUpdate)
							{
								_superPelletsGfx.beginFill(0xFFFF00);
								_superPelletsGfx.drawRect(tx - t2, ty - t3, t4, t6);
								_superPelletsGfx.endFill();
								_superPelletsGfx.beginFill(0xFFFF00);
								_superPelletsGfx.drawRect(tx - t3, ty - t2, t6, t4);
								_superPelletsGfx.endFill();
							}
						}
					}
				}
				
				_superPelletsUpdate = false;
			}
		}
		
		public function keyDownHandler(keyCode : int, charCode : int) : void
		{
			if(keyCode == Keyboard.ESCAPE)
			{
				if(_dying == false)
				{
					_root.save();
					_root.setState("menu");
					
					return;
				}
			}
			
			if(keyCode == Keyboard.SHIFT)
				_keyboardSpeed = 4.0;
			else if(keyCode == Keyboard.LEFT)
				_keyLeftDown = true;
			else if(keyCode == Keyboard.RIGHT)
				_keyRightDown = true;
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