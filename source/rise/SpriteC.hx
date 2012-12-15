package rise;
import engine.entities.C;
import org.flixel.FlxSprite;
import org.flixel.FlxG;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;
import org.flixel.FlxU;

class SpriteC extends C{
	@inject var renderS:RenderS;
	@inject var updateS:UpdateS;
	var flxSprite:FlxSprite;
	
	public var x(getX, setX):Float;
	function getX():Float{
		return flxSprite.x; 
	}
	function setX(v:Float):Float{
		return flxSprite.x = v;
	}
	
	public var y(getY, setY):Float;
	function getY():Float{
		return flxSprite.y; 
	}
	function setY(v:Float):Float{
		return flxSprite.y = v;
	}
	
	public var scaleX(getScaleX, setScaleX):Float;
	function getScaleX():Float{
		return flxSprite.scale.x;
	}
	function setScaleX(v:Float):Float{
		return flxSprite.scale.x = v;
	}

	public var scaleY(getScaleY, setScaleY):Float;
	function getScaleY():Float{
		return flxSprite.scale.y;
	}
	function setScaleY(v:Float):Float{
		return flxSprite.scale.y = v;
	}

	public function getColor():Array<Float> {
		return FlxU.getRGBA(flxSprite.color);
	}
	
	public function setColor(red:Int, green:Int, blue:Int, alpha:Int):UInt {
		return flxSprite.color = FlxU.makeColor(red, green, blue, alpha);
	}
	
	public function init(graphic:Dynamic, x:Float = 0, y:Float = 0, animate:Bool = false, reverse:Bool = false, width:Int = 0, height:Int = 0, unique:Bool = false, key:String = null):Void{
		flxSprite = new FlxSprite();
		flxSprite.loadGraphic(graphic, animate, reverse, width, height, unique, key);
		flxSprite.offset.x = flxSprite.width / 2;
		flxSprite.offset.y = flxSprite.height / 2;
		renderS.add(flxSprite);

		this.x = x;
		this.y = y;		

		m.add(updateS, UpdateS.UPDATE, onUpdate);
	}
	
	override public function destroy():Void{
		super.destroy();
	}
	
	function onUpdate():Void{
	}
}
