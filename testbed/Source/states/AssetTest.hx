package states;

import bakeneko.state.State;
import lime.Assets;

class AssetTest extends State {
	
	override public function onInit():Void {
		//trace(Assets.list());
		var pro = Assets.loadImage('assets/textures/colorGrid.png');
		pro.onComplete(function (image) {
			trace(image.width, image.height);
		});
		pro.onError(function(e) {
			trace(e);
		});
	}
	
}