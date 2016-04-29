package bakeneko.asset;

import bakeneko.core.AppSystem;

@:build(bakeneko.asset.Macros.build('Assets/'))
class AssetManager extends AppSystem {
	
	@assets
	static public var assets;
	
	override public function onInit():Void {
		trace(assets.textures.colorGrid_png);
	}
}