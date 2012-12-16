package rise;
import engine.entities.C;
import engine.entities.E;
import org.flixel.FlxG;
import com.eclecticdesignstudio.motion.MotionPath;
import com.eclecticdesignstudio.motion.Actuate;
import rise.MonsterC.MonsterState;

class NodeBarracksC extends C{
	
	@inject var nodeC:NodeC;
	@inject var updateS:UpdateS;
	@inject var worldS:WorldS;
	
	var monsters : Array<E>;
	var maxMonsterCount = 1;
	
	var spawnCounter : Float = 0;
	var spawnDelay = 1;
	
	public var targetNodeC:NodeC = null;

	public function init():Void{
		monsters = new Array<E>();
		nodeC.goldOffset = -20;
		
		m.add(updateS, UpdateS.UPDATE, onUpdate);
	}
	
	function onUpdate():Void {
		if (nodeC.gold > 40 && monsters.length < maxMonsterCount && spawnCounter > spawnDelay) {			
			nodeC.gold -= 20;
			spawnMonster();
		}
		
		if (spawnCounter > spawnDelay)
			spawnCounter = 0;
			
		spawnCounter += FlxG.elapsed;
		
		if (monsters.length > 0 && targetNodeC == null) { // only start looking for things to attack when i actually have monsters
		
			for(node in worldS.enemyNodes) {
				
				if(U.inCircle(nodeC.x, nodeC.y, Config.BarracksAttackRange, node.getC(NodeC).x, node.getC(NodeC).y)) {
					targetNodeC = node.getC(NodeC);
					
					// dispatch monsters
					for (monster in monsters) {
						trace('dispatching monster to attack ' + targetNodeC);
						monster.getC(MonsterC).attackTarget(targetNodeC);						
					}
				}
			}
			
		}
	}
	
	function spawnMonster():Void {		
		
		var monster = new E(e);
		
		monster.addC(MonsterC).init(nodeC.x, nodeC.y);
		monster.getC(MonsterC).state = MonsterState.inactive;
		monsters.push(monster);
		
		var degrees = Math.random()*360;
		var point = U.pointOnEdgeOfCircle(nodeC.x, nodeC.y, Config.NodeStartRadius + 20, degrees);
		monster.getC(MonsterC).lastDegrees = degrees;
		Actuate.tween(monster.getC(MonsterC), 1, { x: point[0], y:point[1] }).onComplete(function(){
			monster.getC(MonsterC).state = MonsterState.idle;
		});		
		
	}
	
	override public function destroy():Void{
		super.destroy();
	}
}
