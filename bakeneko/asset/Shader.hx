package bakeneko.asset;

import bakeneko.asset.Resource;
import bakeneko.backend.FileLoader;
import bakeneko.backend.opengl.GL;
import bakeneko.backend.opengl.GL.GLShader;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.math.Matrix4x4;
import bakeneko.math.Vector2;
import bakeneko.math.Vector3;
import bakeneko.math.Vector4;
import bakeneko.render.Color;
import bakeneko.render.Material;
import bakeneko.task.Task;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import lime.Assets;

class Shader extends Resource implements IResource {
	
	public var fragmentSource:String;
	public var vertexSource:String;

	public var vertexShader:GLShader;
	public var fragmentShader:GLShader;
	public var program:GLProgram;

	public var verticeAttribute	: Int = 0;
    public var texCoordAttribute: Int = 1;
    public var colorAttribute  	: Int = 2;
    public var normalAttribute 	: Int = 3;
	
	var vertID:String;
	var fragID:String;

	var uniformCache:Map<String, GLUniformLocation>;
	
	public function new(?options:ShaderOptions) {
		super(options);
		resourceType = ResourceType.shader;
		
		if (options != null) {
			if (options.vertID != null && options.fragID != null) {
				vertID = options.vertID;
				fragID = options.fragID;
			}
			
			if (options.vertSource != null && options.fragSource != null) {
				build(options.vertSource, options.fragSource);
			}
		}
	}

	public function reload():Task<Shader> {
		clear();

		uniformCache = new Map();
		
		state = ResourceState.loading;
		var tcs = new TaskCompletionSource<Shader>();
		
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			var tasks = [
				FileLoader.loadText(fragID).onSuccess(function(task:Task<String>) {
					fragmentSource = task.result;
				}),
				FileLoader.loadText(vertID).onSuccess(function(task:Task<String>) {
					vertexSource = task.result;
				})
			];
			
			Task.whenAll(tasks).onSuccess(function(task:Task<Void>) {
				Log.assert(fragmentSource != null, 'Fragment source of $id can\'t be null');
				Log.assert(vertexSource != null, 'Vertex source of $id can\'t be null');
				
				if (build(vertexSource, fragmentSource)) {
					state = ResourceState.loaded;
					tcs.setResult(this);
				} else {
					state = ResourceState.failed;
					tcs.setError('Failed to build shader $id');
					Log.error(tcs.task.error);
				}
			});
		});
		
		return tcs.task;
		
		/*return Task.call(function() {
			
			fragmentSource = FileLoader.getText(fragID);
			vertexSource = FileLoader.getText(vertID);
			
			Log.assert(fragmentSource != null, 'Fragment source of $id can\'t be null');
			Log.assert(vertexSource != null, 'Vertex source of $id can\'t be null');
			
			if (build(vertexSource, fragmentSource)) {
				state = ResourceState.loaded;
			} else {
				state = ResourceState.failed;
				Log.error('Failed to build shader $id');
			}
			
			return this;
		}, TaskExt.BACKGROUND_EXECUTOR).continueWithTask(function(task:Task<Shader>) {
			if (task.isFaulted) {
				throw error;
				Log.error(task.error);
			}
			
			return task;
		});*/
	}

	public function build(vertString:String, fragString:String):Bool {
		clear();

		#if html5
			fragString = "precision mediump float;" + fragString;
		#end

		vertexSource = vertString;
		fragmentSource = fragString;

		vertexShader = compile(GL.VERTEX_SHADER, vertexSource);
		fragmentShader = compile(GL.FRAGMENT_SHADER, fragmentSource);

		link();

		state = ResourceState.loaded;

		return true;
	}

	function compile(type:Int, source:String):GLShader {
		Log.assert(source != null, 'Shader source of $id can\'t be null');
		
		var shader = GL.createShader(type);
		GL.shaderSource(shader, source);
		GL.compileShader(shader);

		var info = GL.getShaderInfoLog(shader);
	
		if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0)
		{
			Log.error('Error trying to compile shader $id\n$info');
			GL.deleteShader(shader);
			return null;
		}

		// Log shader compiler warnings
		if (info.length > 1) {
			Log.info(info);
		}

		return shader;
	}

	function link():Bool {
		program = GL.createProgram();
		GL.attachShader(program, vertexShader);
		GL.attachShader(program, fragmentShader);

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			Log.error(GL.getProgramInfoLog(program));
			GL.deleteProgram(program);
			program = null;
			return false;
		}

		return true;
	}

	// The material must control shader binding
	@:allow(bakeneko.render.Material)
	function bind() {
		GL.useProgram(program);
	}

	// TODO: Try this using macros
	public function setUniform(uniform:String, value:Dynamic, ?fail = true) {
		var location = getLocation(uniform, fail);

		if (location != null)
		{
			switch (Type.typeof(value)) {
				case TInt:
					GL.uniform1i(location, cast value);
				case TFloat:
					GL.uniform1f(location, cast value);
				case TClass(Vector2Base):
					GL.uniform2f(location, cast value.x, cast value.y);
				case TClass(Vector3Base):
					GL.uniform3f(location, cast value.x, cast value.y, cast value.z);
				case TClass(Vector4Base):
					GL.uniform4f(location, cast value.x, cast value.y, cast value.z, cast value.w);
				case TClass(Color):
					GL.uniform4f(location, cast value.r, cast value.g, cast value.b, cast value.a);
				case TClass(Matrix4x4Base):
					GL.uniformMatrix4fv(location, false, cast(value, Matrix4x4).float32Array());
				default:
					Log.error('Unknown uniform type');
			}
		}
	}

	public function clear():Void {
		if (vertexShader != null) 	GL.deleteShader(vertexShader);
		if (fragmentShader != null)	GL.deleteShader(fragmentShader);
		if (program != null)		GL.deleteProgram(program);

		vertexSource = null;
		fragmentSource = null;
	}

	function getLocation(uniform:String, ?fail = true) {
		
		if (uniformCache.exists(uniform))
			return uniformCache.get(uniform);
		
		var location:GLUniformLocation = GL.getUniformLocation(program, uniform);
		Log.assert(location != null || !fail, 'Could not find uniform: $uniform');

		uniformCache.set(uniform, location);
		
		return location;
	}

	public function memoryUsage():Int {
		return fragmentSource.length + vertexSource.length;
	}
}

typedef ShaderOptions = {
	> ResourceOptions,

	@:optional var fragID:String;
	@:optional var vertID:String;
	
	@:optional var fragSource:String;
	@:optional var vertSource:String;
}