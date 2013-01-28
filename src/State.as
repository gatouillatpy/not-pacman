package
{
	import flash.display.Sprite;

	public interface State
	{
		function get view() : Sprite;
		
		function load(root : NotPacman) : void;
		function unload() : void;
		
		function update(dt : Number) : void;
		function draw() : void;
		
		function keyDownHandler(keyCode : int, charCode : int) : void;
		function keyUpHandler(keyCode : int, charCode : int) : void;
		function mouseClickHandler(x : Number, y : Number) : void;
		function mouseMoveHandler(x : Number, y : Number) : void;
		function mouseDownHandler(x : Number, y : Number) : void;
		function mouseUpHandler(x : Number, y : Number) : void;
		function gyroscopeUpdateHandler(x : Number, y : Number, z : Number) : void;
	}
}