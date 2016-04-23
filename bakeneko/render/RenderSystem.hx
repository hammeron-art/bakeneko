package bakeneko.render;

import bakeneko.asset.Resource;
import bakeneko.asset.ResourceManager;
import bakeneko.asset.Shader;
import bakeneko.backend.RenderDriver;
import bakeneko.render.pass.Types;
import bakeneko.render.pass.Pass;
import bakeneko.backend.Surface;
import bakeneko.core.Application;
import bakeneko.core.AppSystem;
import bakeneko.core.Log;
import bakeneko.core.Pair;
import bakeneko.entity.Scene;
import bakeneko.math.Matrix4x4;
import bakeneko.render.Color;
import bakeneko.render.VertexFormat.VertexElement;
import bakeneko.core.Event;
import lime.graphics.Renderer;

/**
 * Rendering system.
 * Do a pre-pass in the scene converting components to plain data to send to the GPU,
 * manages all the graphics api calls and provide statistics (such the number of draw calls, number of create buffers, etc).
 */
class RenderSystem extends AppSystem {

	public var canRender:Bool = false;

	public var defaultFormat(default, null):VertexFormat;
	public var defaultMaterial(default, null):Material;
	// Used to draw mesh with material.wireframe = true
	public var wireMaterial(default, null):Material;
	// Clear color
	public var backColor:Color;
	
	// External render targets (eg Physics debug draw)
	public var customTargets:Array<Surface>;
	public var renderEvent:Event<Void->Void>;
	
	public var driver:RenderDriver;

	// For default/main framebuffer rendering
	
	var screenMaterial:Material;
	// The quad in normalized device coordinates to render the screen
	var quadScreenMesh:Mesh;
	
	var viewMatrix:Matrix4x4;
	var projectionMatrix:Matrix4x4;

	var drawCalls:Int = 0;
	
	var passes:Array<Pass>;
	var currentPass:Pass;
	
	var cameraList:Array<CameraComponent>;
	var cameraSurfaces:Array<Surface>;

	public function new() {
		super();
		
		driver = new RenderDriver();
		driver.init();
		
		passes = [];
		addPass(new Pass());
	}

	public function addPass(pass:Pass) {
		passes.push(pass);
	}
	
	public function applyPass(pass:Pass) {
		currentPass = pass;
	}
	
	override public function onInit():Void {

		customTargets = [];
		backColor = Color.fromInt24(0x2a2b33);
		
		defaultFormat = new VertexFormat();
		defaultFormat.push(new VertexElement(TFloat(3), SPosition));
		defaultFormat.push(new VertexElement(TFloat(4), SColor));
		defaultFormat.push(new VertexElement(TFloat(2), STexcoord));
		
		var screenFormat = new VertexFormat();
		screenFormat.push(new VertexElement(TFloat(2), SPosition));
		screenFormat.push(new VertexElement(TFloat(2), STexcoord));
		
		defaultMaterial = new Material("bkDefault", defaultFormat);
		screenMaterial = new Material("bkScreen", screenFormat);

		var quadScreen:Array<Float> = [
			 -1.0,  1.0, 0.0, 0.0,
			-1.0, -1.0, 0.0, 1.0,
			 1.0, -1.0, 1.0, 1.0,

			-1.0,  1.0, 0.0, 0.0,
			 1.0, -1.0, 1.0, 1.0,
			 1.0,  1.0, 1.0, 0.0,
		];
		
		var data:MeshData = {
			positions: [ [-1.0, 1.0], [-1.0, -1.0], [1.0, -1.0], [-1.0, 1.0], [1.0, -1.0], [1.0, 1.0]],
			uvs: [[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [0.0, 0.0], [1.0, 1.0], [1.0, 0.0]],
		}
		
		quadScreenMesh = new Mesh(data, screenFormat);
		quadScreenMesh.build();
		
		var wFormat = new VertexFormat();
		wFormat.push(new VertexElement(TFloat(3), SPosition));
		
		wireMaterial = new Material("wire", wFormat);
		wireMaterial.wireColor = new Color(1.0, 1.0, 1.0, 1.0);
		
		renderEvent = new Event<Void->Void>();
		
		// Configurations

		driver.enableDepthTest(true);
		driver.enableBlend(true);
		driver.setBlend(Blend.SrcAlpha, Blend.OneMinusSrcAlpha);

		// Shaders
		var defaultShader = new Shader( {
			id: 'bakeneko/shaders/default',
			vertSource: ResourceManager.getEmbeddedString('shaders.default.vs'),
			fragSource: ResourceManager.getEmbeddedString('shaders.default.fs')
		});
		Log.assert(defaultShader.state == ResourceState.loaded, 'Failed to create default Shader');
		defaultMaterial.setShader(defaultShader);

		var screenShader = new Shader( {
			id: 'bakeneko/shaders/screen',
			vertSource: ResourceManager.getEmbeddedString('shaders.screen.vs'),
			fragSource: ResourceManager.getEmbeddedString('shaders.screen.fs')
		});
		Log.assert(screenShader.state == ResourceState.loaded, 'Failed to create screen Shader');
		screenMaterial.setShader(screenShader);
		
		var wireShader = new Shader( {
			id: 'bakeneko/shaders/wire',
			vertSource: ResourceManager.getEmbeddedString('shaders.wire.vs'),
			fragSource: ResourceManager.getEmbeddedString('shaders.wire.fs')
		});
		Log.assert(wireShader.state == ResourceState.loaded, 'Failed to create wire Shader');
		wireMaterial.setShader(wireShader);
		
		/*var cameraList:Array<CameraComponent> = Application.get().stateManager.getCurrentState().scene.queryComponents(CameraComponent);
		cameraList.sort(function(x, y) {
			return x.depth - y.depth;
		});*/
		
		cameraList = [null];
		cameraSurfaces = [null];
		
		canRender = true;
	}
	
	/**
	 * Render main RenderTarget
	 * 
	 * Each camera render drawables to its RenderTarget
	 * and each camera's RenderTarget is rendered to the main RenderTarget
	 */
	@:access(bakeneko.render.CameraComponent)
	public function onRender(renderer:Renderer) {
		if (!canRender)
			return;
		
		startFrame();

		cameraList[0] = CameraComponent.mainCamera;
		cameraSurfaces[0] = renderCamera(cameraList[0]);
		/*var cameraRenders:Array<Surface> = [];
		
		for (camera in cameraList) {
			cameraRenders.push(renderCamera(camera));
		}*/
		
		renderEvent.dispatch();
		
		Surface.bindDefault();
		
		clearColor(backColor);
		clear(Buffer.ColorBufferBit);
		
		quadScreenMesh.bind();
		screenMaterial.apply();
		screenMaterial.setAttributes();

		driver.enableDepthTest(false);

		for (surface in cameraSurfaces) {
			surface.colorTexture.bind();
			drawBuffer(quadScreenMesh);
		}
		
		for (surface in customTargets) {
			surface.colorTexture.bind();
			drawBuffer(quadScreenMesh);
		}

		endFrame();
	}

	public function startFrame() {
		clearFrame();

		drawCalls = 0;
	}

	public function endFrame() {
	}

	// Render camera to its target
	@:access(bakeneko.render.CameraComponent)
	public function renderCamera(camera:CameraComponent):Surface {

		if (camera.autoRedraw) {
			var viewMatrix = camera.entity.transform.getWorld().clone();
			if (camera.projection != null)
				applyCamera(camera.projection, viewMatrix.inverse());

			camera.sortMaterials();
			camera.buildBatches();
			
			driver.setTexture(0, null);
			
			camera.renderTarget.bind();

			clearColor(new Color(0.0, 0.0, 0.0, 0.0));
			clear(Buffer.ColorBufferBit | Buffer.DepthBufferBit);
			driver.enableDepthTest(true);

			for (pass in passes) {
				for (material in camera.sortedByMaterial.keys()) {
					pass.draw(camera.dynamicBatches[material]);
				}
			}
			
			return camera.renderTarget;
		}
		
		return null;
	}

	public function applyCamera(projection:Matrix4x4, view:Matrix4x4) {
		projectionMatrix = projection.clone();
		viewMatrix = view.clone();
	}

	public inline function clearColor(color:Color) {
		driver.clearColor(color);
	}

	public inline function clear(mask:Int) {
		driver.clear(mask);
	}

	public function clearFrame() {
		clearColor(backColor);
		clear(Buffer.ColorBufferBit | Buffer.DepthBufferBit);
	}

	public function drawBuffer(mesh:Mesh, ?material:Material, ?pass:Pass) {
		// Default type
		var primitive = Triangles;

		if (material != null) {
			if (material.visible == false || !material.isReady()) {
				return;
			}

			Log.assert(isEqualFormat(mesh.format, material.vertexFormat), 'Mesh and material (${material.id}) vertexFormat don\'t match');
			
			material.apply();

			if (material.isReady()) {
				material.setAttributes();
				if (projectionMatrix != null)
					material.shader.setUniform('projectionMatrix', projectionMatrix);
				if (viewMatrix != null)
					material.shader.setUniform('viewMatrix', viewMatrix);
			}
		}
		
		if (mesh.indexList.length > 0) {
			drawElements(primitive, mesh.indexList.length, mesh.indexFormat(), 0);
		} else {
			drawArrays(primitive, 0, mesh.getVertexCount());
		}
	}
	
	function drawWireframe(mesh:Mesh, wireWidth:Int, ?material:Material) {
		var prevFunc = driver.getDepthFunction();
		var prevWidth = driver.getLineWidth();
		driver.setDepthFunction(Compare.LessEqual);
		driver.setLineWidth(wireWidth);
			
		wireMaterial.apply();
		//setAttributes(wireMaterial);
		if (projectionMatrix != null)
			wireMaterial.shader.setUniform('projectionMatrix', projectionMatrix);
		if (viewMatrix != null)
			wireMaterial.shader.setUniform('viewMatrix', viewMatrix);
		
		wireMaterial.shader.setUniform('color', material != null ? material.wireColor : wireMaterial.wireColor);
	
		if (true/*mesh.faceList == null && mesh.faceList.length == 0*/) {
			if (mesh.indexList.length > 0) {
				var i = 0;
				while (i < mesh.indexList.length) {
					drawElements(Primitive.LineLoop, 3, mesh.indexFormat(), i * mesh.indexSize());
					i += 3;
				}
			} else {
				var i = 0;
				while(i < mesh.getVertexCount()) {
					drawArrays(Primitive.LineLoop, i, 3);
					i += 3;
				}
			}
		} else {
			
		}

		driver.setDepthFunction(prevFunc);
		driver.setLineWidth(prevWidth);
	}
	
	inline function drawArrays(primitive:Primitive, first:Int, count:Int) {
		driver.drawVertices(primitive, first, count);
		++drawCalls;
	}
	
	inline function drawElements(mode:Primitive, count:Int, type:Int, offset:Int) {
		driver.drawIndexes(mode, count, type, offset);
		++drawCalls;
	}
	
	inline public function addRenderTarget(target:Surface) {
		customTargets.push(target);
	}
	
	public function isEqualFormat(format1:VertexFormat, format2:VertexFormat) {
		if (format1.elements.length != format2.elements.length)
			return false;
		
		for (i in 0...format1.elements.length) {
			if (!(format1.elements[i].semantic == format2.elements[i].semantic && format1.elements[i].type == format2.elements[i].type))
				return false;
		}
		
		return true;
	}

}