package rise;
import engine.entities.C;
import engine.entities.E;
import nme.events.Event;
import org.flixel.FlxG;
import com.eclecticdesignstudio.motion.Actuate;

class NodeFactoryS extends C{
	@inject public var updateS:UpdateS;
	
	public function init():Void{
		createNode(100, 100);
		
		m.add(updateS, UpdateS.UPDATE, onUpdate);
	}
	
	override public function destroy():Void{
		super.destroy();
	}
	
	function onUpdate():Void{
		if(FlxG.mouse.justPressed()){
			createNode(FlxG.mouse.getWorldPosition().x, FlxG.mouse.getWorldPosition().y);
		}
	}
	
	public function createNode(x:Float, y:Float):Void{
		var node:E = new E(e);
		node.addC(SpriteC).init("assets/data/stick.png", x, y);
		
		node.getC(SpriteC).scaleX = 0;
		node.getC(SpriteC).scaleY = 0;
		Actuate.tween(node.getC(SpriteC), 1, {scaleX:1, scaleY:1}).ease(new CustomElasticTween(0.1, 0.2));
		
	}
}







