package;

import bakeneko.core.Application;
import bakeneko.core.Core;

class Main extends Application {

	override public function initialState():Void {
		stateManager.push(new SpriteState());
	}
	
	override public function initConfig(config:AppConfig):AppConfig {
		config.windows[0].title = 'Sprite Test';
		
		return config;
	}
}