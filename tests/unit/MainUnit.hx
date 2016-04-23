import bakeneko.core.Application;
import tests.unit.MathTest;
import tests.unit.ResourceTest;
import tests.unit.ShapeTest;

class MainUnit extends Application {
	
	public function new() {
		super();
		
		var runner = new haxe.unit.TestRunner();

		//runner.add(new ResourceTest());
        runner.add(new MathTest());
		//runner.add(new ShapeTest());
		//runner.add(new TestStress());
		
        runner.run();
    }
	
}