package tests.unit;
import bakeneko.asset.ResourceManager;

class ResourceTest extends BakenekoTestCase
{
	public var manager:ResourceManager;
	
	override public function setup():Void 
	{
		manager = new ResourceManager();
	}

	public function testResource() {
		manager.loadText("test");
		assertTrue(true);
	}
		
}