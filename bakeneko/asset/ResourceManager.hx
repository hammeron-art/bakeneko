package bakeneko.asset;

import bakeneko.asset.Atlas.AtlasOptions;
import bakeneko.asset.Resource.ResourceOptions;
import bakeneko.asset.Texture.TextureOptions;
import bakeneko.asset.Shader.ShaderOptions;
import bakeneko.core.Application;
import bakeneko.core.AppSystem;
import bakeneko.core.Log;
import bakeneko.core.Log;
import bakeneko.task.Task;

/**
 * Manages resource loading, caching, fetch, auto reloading, etc.
 * All interation with resources are designed to by asynchronous and reloadable at runtime
 */
class ResourceManager extends AppSystem {

	private static var cache:Map<String, Map<String, IResource>>;
	// Enable/disable resource reloading
	public var autoSync:Bool;
	
	// Resources like GLSL text for shaders and textures maybe be loaded in a worker thread
	// but OpenGL calls need to be done in the main thread so the resource push a function
	// and we execute this
	var buildCalls:Array<Void->Void>;

	public function new() {
		super();
		
		cache = new Map();
		
		cache.set(Type.getClassName(Json), new Map());
		cache.set(Type.getClassName(Shader), new Map());
		cache.set(Type.getClassName(Font), new Map());
		cache.set(Type.getClassName(Binary), new Map());
		cache.set(Type.getClassName(Text), new Map());
		cache.set(Type.getClassName(Texture), new Map());
		cache.set(Type.getClassName(Atlas), new Map());
		
		buildCalls = [];
	}

	override public function onInit():Void {
		#if (desktop)
			autoSync = true;
		#else
			autoSync = false;
		#end
	}

	public function loadText(options:ResourceOptions):Task<Text> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');

		var resource:Text = find(Text, options.id);

		if (resource != null) {
			Log.info('Text "${options.id}" existed in resource cache.');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Text(options);
		add(Text, resource);

		return resource.reload();
	}
	
	public function loadFont(options:ResourceOptions):Task<Font> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');
		
		var resource:Font = find(Font, options.id);

		if (resource != null) {
			Log.info('${resource.typeString()} / existed / "${options.id}"');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Font(options);
		add(Font, resource);

		return resource.reload();
	}

	public function loadShader(options:ShaderOptions):Task<Shader> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');

		var resource:Shader = find(Shader, options.id);

		if (resource != null) {
			Log.info('${resource.typeString()} / existed / "${options.id}"');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Shader(options);
		add(Shader, resource);

		return resource.reload();
	}

	public function loadTexture(options:TextureOptions):Task<Texture> {
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
	
	public function loadAtlas(options:AtlasOptions):Task<Atlas> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');
		
		var resource:Atlas = find(Atlas, options.id);

		if (resource != null) {
			Log.info('${resource.typeString()} / existed / "${options.id}"');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Atlas(options);
		add(Atlas, resource);

		return resource.reload();
	}

	public function loadJson(options:ResourceOptions):Task<Json> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');
		
		var resource:Json = find(Json, options.id);

		if (resource != null) {
			Log.info('${resource.typeString()} / existed / "${options.id}"');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Json(options);
		add(Json, resource);

		return resource.reload();
	}

	public function loadBinary(options:ResourceOptions):Task<Binary> {
		Log.assert(options.id != null, 'Resource id can\'t be null when load from files.\nMust be the file path.');
		
		var resource:Binary = find(Binary, options.id);

		if (resource != null) {
			Log.info('${resource.typeString()} / existed / "${options.id}"');
			resource.refCount++;
			return Task.call(function() {
				return resource;
			});
		}

		resource = new Binary(options);
		add(Binary, resource);

		return resource.reload();
	}

	@:generic public function add<T:IResource>(type:Class<T>, resource:IResource) {
		var name = Type.getClassName(type);

		Log.assert(cache.get(name).exists(resource.id) == false, 'A resource with this id ${resource.id} already exists');
		cache.get(name).set(resource.id, resource);
	}

	@:generic public function find<T:IResource>(type:Class<T>, id:String):T {
		return cast cache.get(Type.getClassName(type)).get(id);
	}

	public function reload(path:String) {
		if (!autoSync)
			return;

		for (type in cache) {
			for (id in type.keys()) {
				var r = new EReg(id, 'i');

				if (r.match(path)) {
					type.get(id).reload();
					Log.info('The resource "$id" was automatically reloaded');
				}
			}
		}
	}
	
	inline static public function getEmbeddedString(name:String) {
		Log.assert(haxe.Resource.listNames().indexOf(name) != -1, 'Embedded resource $name not found');
		return haxe.Resource.getString(name);
	}
	
	inline static public function getEmbeddedBytes(name:String) {
		Log.assert(haxe.Resource.listNames().indexOf(name) != -1, 'Embedded resource $name not found');
		return haxe.Resource.getBytes(name);
	}
	
	inline static public function getEmbeddedList() {
		return haxe.Resource.listNames();
	}
	
	public function addBuildCall(func:Void->Void) {
		buildCalls.push(func);
	}
	
	override public function onUpdate(delta:Float):Void {
		while (buildCalls.length != 0) {
			buildCalls.pop()();
		}
	}

}