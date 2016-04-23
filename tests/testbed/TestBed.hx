
import bakeneko.core.Application;
import bakeneko.input.InputSystem.Key;
import snow.api.buffers.Float32Array;

/**
 * ...
 * @author Christian
 */
class TestBed extends Application {

	var state:Int = 0;
	var verticeArray:Float32Array;

	/**
	 * Application configuration
	 * Called when app is initialized
	 *
	 * @param	config
	 * @return
	 */
	override public function initConfig(config:AppConfig):AppConfig {
		config.window.title = "TestBed";
		config.window.width = 800;
		config.window.height = 600;
		return config;
	}

	override public function onInit():Void {
		//Application.core.app.windowing.enable_vsync(true);
	}

	override public function initialState():Void {
		stateManager.push(new SpriteTest());
	}
	
	override public function onUpdate(delta:Float):Void {
		if (input.keypressed(Key.escape)) {
			Application.core.app.shutdown();
		}
	}
}