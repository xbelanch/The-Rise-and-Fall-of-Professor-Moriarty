package rise;
import engine.entities.C;
import engine.entities.E;
import flash.events.Event;
import org.flixel.FlxG;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Elastic;
import rise.MonsterC.MonsterState;
import org.flixel.FlxGroup;
import haxe.Json;

enum NodeState {
	inactive;
	active;
	dragging;
}

enum NodeType {
	barracks;
	mine;
	castle;
	road;
}

class NodeC extends C{
	public var name:String;
	
	public static inline var MOVED = "MOVED";
	@inject var worldS:WorldS;
	@inject var renderS:RenderS;
	@inject var updateS:UpdateS;
	@inject var scrollS:ScrollS;
	
	var circle:E;
	public var graphic:E;
	public var edges:Array<E>;
	public var agents:Array<E>;
	public var attackers:Array<E>;
	
	var _gold:Int = 100;
	public var gold(getGold, setGold):Int;
	function getGold():Int{
		return _gold;
	}
	function setGold(v:Int):Int{
		var area = v / 100.0;
		if(area <= 0){
			updateS.kill(e);
		}		
		setRadius(Math.sqrt(area / Math.PI) * originalGraphicSize / 2);
		return _gold = v;
	}
		
	public var decayRate:Float = 5;
	var decayCounter:Float = 0;
	var sendCounter:Float= 0;
	public var decline:Bool = false;
	public var originalGraphicSize:Float;
	public var targetScaleFactor:Float = 2;
	public var maxGold:Int = 99999;
	
	public var state(default, default):NodeState;
	public var mine(default, default):Bool;
	
	public var x(getX, setX):Float;
	function getX():Float{
		return circle.getC(SpriteC).x; 
	}
	function setX(v:Float):Float{
		graphic.getC(SpriteC).x = v;
		var r = circle.getC(SpriteC).x = v;
		dispatchEvent(new Event(MOVED));
		return r;
	}
	
	public var y(getY, setY):Float;
	function getY():Float{
		return circle.getC(SpriteC).y;
	}
	function setY(v:Float):Float{
		graphic.getC(SpriteC).y = v;
		var r = circle.getC(SpriteC).y = v;
		dispatchEvent(new Event(MOVED));
		return r;
	}
	
	// prolly do something with the radius itself
	var _radius:Float;
	public var radius(getRadius, setRadius):Float;
	function setRadius(v:Float):Float {
		var targetScale = (v / originalGraphicSize) * targetScaleFactor;
		Actuate.stop(circle.getC(SpriteC));
		Actuate.tween(circle.getC(SpriteC), 1, {scaleX:targetScale, scaleY:targetScale}).ease(Elastic.easeOut);
		return _radius = v;
	}
	function getRadius():Float {
		return _radius;
	}
	
	public var circleSprite(getCircleSprite, null):SpriteC;
	function getCircleSprite():SpriteC {
		return circle.getC(SpriteC);
	}
	
	public function init(g : Dynamic, ?layer:FlxGroup, x : Float, y : Float, gold:Int, decayRate:Float, ?state : NodeState = null, ?mine:Bool = true):Void{
		name = Math.random() + "";
		
		if (state == null)
			this.state = NodeState.inactive;
		else 
			this.state = state;
			
		if (layer == null)
			layer = renderS.defaultLayer;
		
		edges = new Array<E>();
		agents = new Array<E>();
		attackers = new Array<E>();
		
		// grpahics
		this.mine = mine;
		this.circle = createCircle(layer);
		circle.getC(SpriteC).scaleX = circle.getC(SpriteC).scaleY = 0;
		this.graphic = createGraphic(g, layer);
		
		// position and size
		this.x = x;
		this.y = y;
		this.radius = radius;
		
		this.gold = gold;
		this.decayRate = decayRate;
		
		worldS.addNode(e);
		m.add(updateS, UpdateS.UPDATE, onUpdate);
	}
		
	function onUpdate():Void {
		decline = decline || isUnderAttack();
		 
		if (this.state == NodeState.dragging) {
			if (FlxG.mouse.justReleased()) {
				// check if able to drop there
				scrollS.enabled = true;
				if (e.hasC(FollowMouseC)) {
					e.getC(FollowMouseC).enabled = false;
				} 
				
				if (e.hasC(NodeRoadC)) { // vanish road and create new edge
					
					var closestNode = worldS.getClosestBuilding(x, y, mine);
					if (U.distance(closestNode.getC(NodeC).x, closestNode.getC(NodeC).y, x, y) > Config.NodeStartRadius) {
						// refund
					} else {
						// reconnect 
						worldS.createEdge(closestNode, edges[0].getC(EdgeC).getEndPoint(e));
					}
						
					updateS.kill(e);
				} else {									
					this.state = NodeState.active;
				}
				
			}
		} else if (this.state == NodeState.active){
			decayCounter += FlxG.elapsed;
			while(decayRate > 0 && decayCounter > decayRate){
				decayCounter -= decayRate;
				evaporate();
			}
			
			sendCounter += FlxG.elapsed;
			while(sendCounter > Config.SendRate){
				sendCounter -= Config.SendRate;		
				edges.sort(function(edge1, edge2){
					var other1 = edge1.getC(EdgeC).getEndPoint(e);
					var other2 = edge2.getC(EdgeC).getEndPoint(e);
					
					if (other1.getC(NodeC).state != NodeState.active) // move inactive ones to bottom 
						return 1;
					if (other2.getC(NodeC).state != NodeState.active)
						return -1;
					
					var b = other1.getC(NodeC).getTimeUntilDeath() < other2.getC(NodeC).getTimeUntilDeath();
					return b?-1:1; 
				});
				
				//var targets = Lambda.array(Lambda.filter(edges, function(edge){}));
				
				var otherNode = null;
				if(edges.length>0){
					otherNode = edges[0].getC(EdgeC).getEndPoint(e).getC(NodeC);
				} 
				if((edges.length > 0) && (decline || gold > maxGold || otherNode.getTimeUntilDeath() < getTimeUntilDeath())){
					if((otherNode.state != NodeState.active) || otherNode.decline) // if the most important edge node is inactive dont send any gold 
						break;
						
					if(!e.hasC(NodeGoldC) && otherNode.e.hasC(NodeMineC)){
						break;
					}
					
					if(!(e.hasC(NodeGoldC) && otherNode.mine) && otherNode.getEffectiveGold() > otherNode.maxGold){
						break;
					}
					
					//if(e.hasC(NodeGoldC) && otherNode.e.hasC(NodeMineC) && otherNode.mine){
					if(!otherNode.mine && otherNode.e.hasC(NodeMineC)){
					}else{
						gold -= Config.AgentSize;
					}
					
					worldS.createGoldAgent(e, edges[0].getC(EdgeC).getEndPoint(e), Config.AgentSize, mine);
				}
			}			
		}
	}
	
	function isUnderAttack():Bool{
		for(attacker in attackers){
			if(attacker.getC(MonsterC).state == MonsterState.combat) return true;
		}
		
		return false;
	}
	
	function evaporate():Void{
		gold -= Config.Evaporation;
	}
	
	function createCircle(layer:FlxGroup):E{
		var e = new E(e);
		e.addC(SpriteC).init('assets/rise_circle_highlight.png', layer);		
		if (mine)
			e.getC(SpriteC).setColor(209, 214, 223, 225);
		else
			e.getC(SpriteC).setColor(54, 45, 34, 225);
		originalGraphicSize = e.getC(SpriteC).flxSprite.width;
		return e;
	}
	
	function createGraphic(graphic, layer:FlxGroup):E{
		var e = new E(e);
		e.addC(SpriteC).init(graphic, layer);
		return e;
	}
	
	public function addEdge(e:E):Void{
		if(!e.hasC(EdgeC)) throw "no EdgeC";
		edges.push(e);
	}
	
	public function removeEdge(e:E):Void{
		edges.remove(e);
	}
	
	public function isBuilding():Bool {
		return (e.hasC(NodeBarracksC) || e.hasC(NodeCastleC) || e.hasC(NodeMineC));
	}
	
	override public function destroy():Void{
		super.destroy();
		worldS.removeNode(e);
	}
	
	public var goldOffset:Int = 0;
	public function getEffectiveGold():Int{
		var total = 0;
		for(agent in agents){
			total += agent.getC(NodeC).gold;
		}
		return cast Math.max(total + gold + goldOffset, 0);
	}
	
	public function getTimeUntilDeath():Float{
		if(decayRate == 0) return Math.POSITIVE_INFINITY;
		return getEffectiveGold() / Config.Evaporation * decayRate;
	}
	
	public function getDistance(other:E):Float{
		return U.distance(x, y, other.getC(NodeC).x, other.getC(NodeC).y);
	}
}






