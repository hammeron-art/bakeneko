package states;

import bakeneko.asset.AssetManager;
import bakeneko.asset.Asset;
import bakeneko.state.State;
import bakeneko.task.Task;
import lime.Assets;

class AssetTest extends State {
	
	override public function onInit():Void {
		//trace(Assets.list());
		/*var pro = Assets.loadImage('assets/textures/colorGrid.png');
		pro.onComplete(function (image) {
			trace(image.width, image.height);
		});
		pro.onError(function(e) {
			trace(e);
		});*/
		
		/*var tasks:Array<Task<Asset>> = [];
		
		var image = Assets.getImage(AssetManager.assets.textures.colorGrid_png);
		trace(image.width, image.height);*/
		//trace(AssetManager.assets.textures.colorGrid_png);
		
		var textureTask = app.assets.loadTexture({id: AssetManager.assets.textures.colorGrid_png});	
		
		textureTask.continueWith(function(task) {
			trace(task.result.image.width);
		});
	}
	
}