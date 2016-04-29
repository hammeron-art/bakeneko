package bakeneko.asset;

import bakeneko.asset.Texture.TextureProp;
import bakeneko.core.AppSystem;
import bakeneko.core.Log;
import bakeneko.task.Task;

@:build(bakeneko.asset.Macros.build('Assets/'))
class AssetManager extends AppSystem {
	
	@assets
	static public var assets;
	
	private static var cache:Map<String, Map<String, Asset>>;
	
	public function new() {
		super();
		
		cache = new Map();
	
		/*cache.set(Type.getClassName(Json), new Map());
		cache.set(Type.getClassName(Shader), new Map());
		cache.set(Type.getClassName(Font), new Map());
		cache.set(Type.getClassName(Binary), new Map());
		cache.set(Type.getClassName(Text), new Map());
		cache.set(Type.getClassName(Atlas), new Map());*/
		cache.set(Type.getClassName(Texture), new Map());
	}
	
	override public function onInit():Void {
		trace(assets.text.text_txt);
	}
	
	public function loadTexture(options:TextureProp):Task<Texture> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');
		
		var resource:Texture = find(Texture, options.id);

		if (resource != null) {
			Log.info('${resource.typeString()} / existed / "${options.id}"');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Texture(options);
		add(Texture, resource);

		return resource.reload();
	}
	
	@:generic public function add<T:Asset>(type:Class<T>, resource:Asset) {
		var name = Type.getClassName(type);

		Log.assert(cache.get(name).exists(resource.id) == false, 'A resource with this id ${resource.id} already exists');
		cache.get(name).set(resource.id, resource);
	}

	@:generic public function find<T:Asset>(type:Class<T>, id:String):T {
		return cast cache.get(Type.getClassName(type)).get(id);
	}
}