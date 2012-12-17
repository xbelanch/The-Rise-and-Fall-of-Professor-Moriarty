package rise;
import engine.entities.C;
import engine.entities.E;
import org.flixel.FlxG;
import rise.NodeC.NodeType;
import rise.NodeC.NodeState;

class GenerateNodeC extends C{
	
	@inject var worldS:WorldS;
	
	var squareSize:Int = 2500;
	
	public function init():Void{
		// generate nearby content
		
		var mineCount = 10;
		var villageCount = 2;
		var mountainCount = 5;

		for (z in 0...mountainCount) {
			var point = validPosition([0,0]);
			worldS.createMountain(point[0], point[1]);
		}

		for (i in 0...mineCount){
			var point = validPosition([0,0]);
			var centerNode = worldS.createGold(point[0], point[1], Std.random(6) * 10 + 50);
			
			// have valid first point
			var clusterCount = Std.random(6) + 2;
			for (z in 0...clusterCount) {
				var clusterPoint = validPosition(point, Config.RandomizerGoldClusterRadius);
				worldS.createGold(clusterPoint[0], clusterPoint[1], Std.random(6) * 10 + 50);				
			}			
		}
		
		for (i in 0...villageCount) {
			var castleCount = Std.random(2) + 1;
			var barracksCount = Std.random(2) + 1;
			var minerCount = 1;
			
			var point = randomPointInSquareCoord(0, 0);
			while (!worldS.isEmptySpot(point[0], point[1])) {
				point = randomPointInSquareCoord(0, 0);
			}
			
			var centerCastleE = worldS.createCastle(point[0], point[1], 200, false);
			centerCastleE.getC(NodeC).state = active;
			
			for (z in 0...castleCount) {
				createNodeType(point, NodeType.castle, centerCastleE, Config.RandomizerVillageClusterRadius);
			}
			
			for (z in 0...minerCount) {
				var p = createNodeType(point, NodeType.mine, centerCastleE, Config.RandomizerVillageClusterRadius);
				worldS.createGold(p[0]+100, p[1], 100);
			}
			
			for (z in 0...barracksCount) {
				createNodeType(point, NodeType.barracks, centerCastleE, Config.RandomizerVillageClusterRadius);
			}			
		}
	}
	
	function createNodeType(startingPoint:Array<Int>, type:NodeType, fromE:E, distance:Int = 0):Array<Int> {
		var p = validPosition(startingPoint, distance);
		worldS.createNodeFromEntity(fromE, p[0], p[1], type, false);
		return p;
	}
	
	function validPosition(point:Array<Int>, distance:Int = 0):Array<Int> {
		var p:Array<Int>;
		if (distance > 0) // it's a cluster request if an distancei s involved
			p = randomPointNearPoint(point[0], point[1], distance); 
		else {
			p = randomPointInSquareCoord(point[0], point[1]);
		}
		
		var d = distance;
		var da = 4; // number of attempts before increasing distance
		while (!worldS.isEmptySpot(p[0], p[1], distance)) {
			
			if (d > 0) { // cluster
				if (da <= 0) {						
					d += 10;
					da = 4;
				}
				
				p = randomPointNearPoint(point[0], point[1], d);
				da--;	
			} else { // grid
				p = randomPointInSquareCoord(point[0], point[1]);			
			}
		}
		
		return p;
	}
	
	function randomPointInSquareCoord(x:Int, y:Int):Array<Int> {
		var halfSquareSize = Std.int(squareSize/2);
		return [Std.random(squareSize) - halfSquareSize  + (x * halfSquareSize), Std.random(squareSize) - halfSquareSize + (y * halfSquareSize)];
	}
	
	function randomPointNearPoint(x:Int, y:Int, maxDistance:Int):Array<Int> {
		var halfDistance = Std.int(maxDistance/2);
		return [ Std.random(maxDistance) - halfDistance + x, Std.random(maxDistance) - halfDistance + y];
	}
	
	override public function destroy():Void{
		super.destroy();
	}
}