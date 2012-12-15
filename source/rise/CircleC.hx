package rise;
import engine.entities.C;
import org.flixel.FlxG;
import org.flixel.FlxGroup;

class CircleC extends C{
	
	@inject var renderS:RenderS;
	
	public var x(getX, setX):Float;
	function getX():Float{
		return e.getC(SpriteC).x; 
	}
	function setX(v:Float):Float{
		return e.getC(SpriteC).x = v;
	}
	
	public var y(getY, setY):Float;
	function getY():Float{
		return e.getC(SpriteC).y;
	}
	function setY(v:Float):Float{
		return e.getC(SpriteC).y = v;		
	}
	
	// prolly do something with the radius itself
	public var radius(getRadius, setRadius):Float;
	function setRadius(v:Float):Float {
		var targetScale = (v / Config.NodeCircleImageSize ) * 2;
		e.getC(SpriteC).scaleY = targetScale;
		return e.getC(SpriteC).scaleX = targetScale;
	}
	function getRadius():Float {
		return (e.getC(SpriteC).scaleX * Config.NodeCircleImageSize) / 2;
	}
	
	public function init(x:Float, y:Float, ?layer:FlxGroup, ?color:Array<Int>):Void{
		if (layer == null)
			layer = renderS.defaultLayer;
		
		e.addC(SpriteC).init('assets/rise_circle_highlight.png', layer, x, y);
		if (color != null)
			e.getC(SpriteC).setColor(color[0], color[1], color[2], color[3]);
		this.radius = Config.NodeStartRadius;
	}
	
	override public function destroy():Void{
		super.destroy();
	}
}






