package rise;
import engine.entities.C;
import engine.entities.E;
import nme.events.Event;
import org.flixel.FlxG;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic.ElasticEaseOut;

class WorldS extends C{
	@inject var updateS:UpdateS;
	
	public function init():Void{
		var c1 = createCastle(FlxG.width/2, FlxG.height/2);
		//createNext(FlxG.width/2, FlxG.height/2);
		
		m.add(updateS, UpdateS.UPDATE, onUpdate);
	}
	
	var last:E;
	function onUpdate():Void{
		if(FlxG.mouse.justPressed()){
			var pos = FlxG.mouse.getWorldPosition();
			createNext(pos.x, pos.y);
		}
	}
	
	function createNext(x:Float, y:Float):Void{
		var newC = createCastle(x,y);
		newC.addC(FollowMouseC).init();
		if(last != null){
			createEdge(last, newC);
			if(last.hasC(FollowMouseC)){
				last.getC(FollowMouseC).enabled = false;
			}
		}
		last = newC;
	}
	
	override public function destroy():Void{
		super.destroy();
	}
	
	function createNode(graphic:Dynamic, x:Float, y:Float):E{
		var e = new E(e);
		e.addC(NodeC).init(graphic, x, y);
		return e;
	}
	
	public function createCastle(x:Float, y:Float):E{
		var e = createNode("assets/rise_icon_home_blue.png", x, y);
		e.addC(NodeCastleC).init();
		e.addC(RadialMenuC).init();
		return e;
	}
	
	public function createGoldMine(x:Float, y:Float):E{
		return null;
	}
	
	public function createEdge(node1:E, node2:E):E{
		var e = new E(e);
		var bmd = FlxG.createBitmap(1, 1, 0xffffffff, false, "WorldS.createEdge");
		
		e.addC(SpriteC).init(bmd, node1.getC(NodeC).x, node1.getC(NodeC).y, false, false, 0, 0, false, "WorldS.createEdge");
		e.addC(EdgeC).init(node1, node2);
		return e;
	}
}







